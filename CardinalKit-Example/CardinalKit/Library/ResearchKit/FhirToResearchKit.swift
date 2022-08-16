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
            let questionnaire = try decoder.decode(Questionnaire.self, from: data)
            if let item = questionnaire.item {
                steps = self.fhirQuestionnaireItemsToORKSteps(questions: item, title: title)

                if let summaryStep = summaryStep {
                    steps += [summaryStep]
                }

                task = ORKNavigableOrderedTask(identifier: identifier, steps: steps)
                constructNavigationRules(questions: item, task: task)
            }
        } catch {
            print("Failed to instantiate FHIR Questionnaire: \(error)")
        }

        return task
    }

    private func fhirQuestionnaireItemsToORKSteps(questions: [QuestionnaireItem], title: String) -> [ORKStep] {
        var surveySteps = [ORKStep]()
        for question in questions {
            if let step = fhirQuestionnaireItemToORKQuestionStep(question: question, title: title) {
                surveySteps += [step]
            }
        }
        return surveySteps
    }

    private func constructNavigationRules(questions: [QuestionnaireItem], task: ORKNavigableOrderedTask) {
        let INVALID_OPERATOR = "Operator is not supported."

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
                            print(INVALID_OPERATOR)
                        }
                    case .boolean(let boolean):
                        if let booleanValue = boolean.value?.bool {
                            switch fhirOperator {
                            case .equal:
                                predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: !booleanValue)
                            case .notEqual:
                                predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: booleanValue)
                            default:
                                print(INVALID_OPERATOR)
                            }
                        }
                    case .date(let fhirDate):
                        do {
                            let date = try fhirDate.value?.asNSDate() as? Date
                            switch fhirOperator {
                            case .equal:
                                predicate = ORKResultPredicate.predicateForDateQuestionResult(with: resultSelector, minimumExpectedAnswer: date, maximumExpectedAnswer: date)
                            case .greaterThan:
                                predicate = ORKResultPredicate.predicateForDateQuestionResult(with: resultSelector, minimumExpectedAnswer: date, maximumExpectedAnswer: nil)
                            case .lessThan:
                                predicate = ORKResultPredicate.predicateForDateQuestionResult(with: resultSelector, minimumExpectedAnswer: nil, maximumExpectedAnswer: date)
                            default:
                                print(INVALID_OPERATOR)
                            }
                        } catch {
                            print("Error converting FHIRDate to NSDate.")
                        }
                    case .integer(let integerValue):
                        guard let integerValue = integerValue.value?.integer else { return }
                        switch fhirOperator {
                        case .equal:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, expectedAnswer: Int(integerValue))
                        case .lessThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, maximumExpectedAnswerValue: Double(integerValue))
                        case .greaterThanOrEqual:
                            predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: resultSelector, minimumExpectedAnswerValue: Double(integerValue))
                        default:
                            print(INVALID_OPERATOR)
                        }
                    default:
                        print("The answer type in this predicate isn't yet supported.")
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

        let answer = fhirQuestionnaireItemToORKAnswerFormat(question: question)
        let questionStep = ORKQuestionStep(identifier: identifier, title: title, question: questionText, answer: answer)
        return questionStep
    }

    private func fhirQuestionnaireItemToORKAnswerFormat(question: QuestionnaireItem) -> ORKAnswerFormat {
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
                    print("There are no options.")
                }
            case .date:
                answer = ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
            case .decimal:
                answer = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
            case .integer:
                answer = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
            case .text:
                answer = ORKTextAnswerFormat()
            case .string:
                answer = ORKTextAnswerFormat()
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
