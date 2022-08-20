//
//  FhirToResearchKit.swift
//  CardinalKit
//
//  Created by Vishnu Ravi on 6/21/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ModelsR4
import ResearchKit

class FhirToResearchKit {

    enum ConversionErrors: Error {
        case unsupportedOperator
        case unsupportedAnswer
        case noOptions
        case invalidDate
    }

    /// This method converts a FHIR Questionnaire defined in JSON into a ResearchKit ORKOrderedTask
    ///
    /// - Parameters:
    ///   - identifier: A unique string to identify this ORKOrderedTask
    ///   - json: A string containing a valid FHIR Questionnaire in JSON
    ///   - title: The title of the questionnaire to be displayed in the ResearchKit Task
    /// - Returns: ORKOrderedTask
    public func convertFhirQuestionnaireToORKOrderedTask(identifier: String, json: String, title: String, summaryStep: ORKCompletionStep? = nil) -> ORKNavigableOrderedTask {
        var steps = [ORKStep]()
        var task = ORKNavigableOrderedTask(identifier: identifier, steps: steps)

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            // Deserialize JSON into a FHIR Questionnaire object
            let questionnaire = try decoder.decode(Questionnaire.self, from: data)
            if let item = questionnaire.item {

                // Convert each FHIR Questionnaire Item to an ORKStep
                steps = self.fhirQuestionnaireItemsToORKSteps(questions: item, title: title)

                // Add a summary step at the end of the task if defined
                if let summaryStep = summaryStep {
                    steps += [summaryStep]
                }

                task = ORKNavigableOrderedTask(identifier: identifier, steps: steps)

                // If any questions have defined skip logic, convert to ResearchKit navigation rules
                try constructNavigationRules(questions: item, task: task)
            }
        } catch ConversionErrors.unsupportedOperator {
            print("An unsupported operator was used.")
        } catch ConversionErrors.unsupportedAnswer {
            print("An unsupported answer type was used.")
        } catch ConversionErrors.invalidDate {
            print("An invalid date was found.")
        } catch {
            print("Failed to instantiate FHIR Questionnaire: \(error)")
        }

        return task
    }

    private func fhirQuestionnaireItemsToORKSteps(questions: [QuestionnaireItem], title: String) -> [ORKStep] {
        var surveySteps = [ORKStep]()
        for question in questions {

            // Convert a group of questions
            if question.type == QuestionnaireItemType.group {
                if let groupStep = fhirGroupToORKFormStep(question: question, title: title) {
                    surveySteps += [groupStep]
                }
            } else {
                // Convert individual questions
                if let step = fhirQuestionnaireItemToORKQuestionStep(question: question, title: title) {
                    if let required = question.required?.value?.bool {
                        step.isOptional = !required
                    }
                    surveySteps += [step]
                }
            }
        }
        return surveySteps
    }

    /**
     This method converts predicates contained in the  "enableWhen" property on FHIR QuestionnaireItem to a ResearchKit ORKPredicateSkipStepNavigationRule.
     */
    private func constructNavigationRules(questions: [QuestionnaireItem], task: ORKNavigableOrderedTask) throws {
        for question in questions {
            guard let questionId = question.linkId.value?.string else { return }

            if let enableWhen = question.enableWhen {
                for fhirPredicate in enableWhen {
                    let fhirOperator = fhirPredicate.`operator`.value
                    guard let enableQuestionId = fhirPredicate.question.value?.string else { return }
                    let resultSelector = ORKResultSelector(resultIdentifier: enableQuestionId)
                    var rule: ORKPredicateSkipStepNavigationRule?
                    var predicate: NSPredicate?

                    switch fhirPredicate.answer {
                    case .coding(let coding):
                        switch fhirOperator {
                        case .exists, .equal:
                            if let matchValue = coding.code?.value?.string {
                                let matchingPattern = "^(?!\(matchValue)).*$"
                                predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, matchingPattern: matchingPattern)
                            }
                        default:
                            throw ConversionErrors.unsupportedOperator
                        }
                    case .boolean(let boolean):
                        if let booleanValue = boolean.value?.bool {
                            switch fhirOperator {
                            case .equal:
                                predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: !booleanValue)
                            case .notEqual:
                                predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: booleanValue)
                            default:
                                throw ConversionErrors.unsupportedOperator
                            }
                        }
                    case .date(let fhirDate):
                        do {
                            let date = try fhirDate.value?.asNSDate() as? Date
                            switch fhirOperator {
                            case .greaterThan:
                                predicate = ORKResultPredicate.predicateForDateQuestionResult(with: resultSelector, minimumExpectedAnswer: nil, maximumExpectedAnswer: date)
                            case .lessThan:
                                predicate = ORKResultPredicate.predicateForDateQuestionResult(with: resultSelector, minimumExpectedAnswer: date, maximumExpectedAnswer: nil)
                            default:
                                throw ConversionErrors.unsupportedOperator
                            }
                        } catch {
                            throw ConversionErrors.invalidDate
                        }
                    case .integer(let integerValue):
                        guard let integerValue = integerValue.value?.integer else { return }
                        switch fhirOperator {
                        case .notEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(integerValue))
                        case .lessThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue: Double(integerValue))
                        case .greaterThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, maximumExpectedAnswerValue: Double(integerValue))
                        default:
                            throw ConversionErrors.unsupportedOperator
                        }
                    case .decimal(let decimalValue):
                        guard let decimalValue = decimalValue.value?.decimal else { return }
                        switch fhirOperator {
                        case .lessThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue: decimalValue.doubleValue)
                        case .greaterThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, maximumExpectedAnswerValue: decimalValue.doubleValue)
                        default:
                            throw ConversionErrors.unsupportedOperator

                        }
                    default:
                        throw ConversionErrors.unsupportedAnswer
                    }

                    if let predicate = predicate {
                        rule = ORKPredicateSkipStepNavigationRule(resultPredicate: predicate)
                    }

                    if let rule = rule {
                        task.setSkip(rule, forStepIdentifier: questionId)
                    }
                }
            }
        }
    }

    private func fhirQuestionnaireItemToORKQuestionStep(question: QuestionnaireItem, title: String) -> ORKQuestionStep? {
        guard let questionText = question.text?.value?.string,
              let identifier = question.linkId.value?.string else { return nil }

        let answer = try? fhirQuestionnaireItemToORKAnswerFormat(question: question)
        let questionStep = ORKQuestionStep(identifier: identifier, title: title, question: questionText, answer: answer)
        return questionStep
    }

    private func fhirGroupToORKFormStep(question: QuestionnaireItem, title: String) -> ORKFormStep? {
        guard let id = question.linkId.value?.string else { return nil }
        guard let nestedQuestions = question.item else { return nil }

        let formStep = ORKFormStep(identifier: id)
        formStep.title = title
        var formItems = [ORKFormItem]()

        for question in nestedQuestions {
            if let questionId = question.linkId.value?.string,
               let questionText = question.text?.value?.string,
                let answerFormat = try? fhirQuestionnaireItemToORKAnswerFormat(question: question) {
                let formItem = ORKFormItem(identifier: questionId, text: questionText, answerFormat: answerFormat)
                formItems.append(formItem)
            }
        }
        
        formStep.formItems = formItems
        return formStep
    }

    private func fhirQuestionnaireItemToORKAnswerFormat(question: QuestionnaireItem) throws -> ORKAnswerFormat {
        var answer = ORKAnswerFormat()

        if let type = question.type.value {
            switch(type) {
            case .boolean:
                answer = ORKBooleanAnswerFormat.booleanAnswerFormat()
            case .choice:
                let answerOptions = fhirChoicesToORKTextChoice(question)
                if answerOptions.count > 0 {
                    answer = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: answerOptions)
                } else {
                    throw ConversionErrors.noOptions
                }
            case .date:
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
            case .decimal:
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            case .integer:
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            case .text, .string:
                answer = ORKTextAnswerFormat(maximumLength: Int(question.maxLength?.value?.integer ?? 0))
            case .time:
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
            default:
                answer = ORKTextAnswerFormat()
            }
        }
        return answer
    }

    private func fhirChoicesToORKTextChoice(_ question: QuestionnaireItem) -> [ORKTextChoice] {
        var choices = [ORKTextChoice]()
        if let answerOptions = question.answerOption {
            for option in answerOptions {
                if case let .coding(coding) = option.value,
                   let display = coding.display?.value?.string,
                   let code = coding.code?.value?.string {
                    let choice = ORKTextChoice(text: display, value: code as NSCoding & NSCopying & NSObjectProtocol)
                    choices.append(choice)
                }
            }
        }
        return choices
    }

}

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
