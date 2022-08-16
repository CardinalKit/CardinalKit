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
    public func convertFhirQuestionnaireToORKOrderedTask(identifier: String, json: String, title: String) -> ORKNavigableOrderedTask {
        var steps = [ORKStep]()
        var task = ORKNavigableOrderedTask(identifier: identifier, steps: steps)

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let questionnaire = try decoder.decode(Questionnaire.self, from: data)
            if let item = questionnaire.item {
                steps = self.fhirQuestionnaireItemsToORKSteps(questions: item, title: title)

                // add a summary step
                let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
                summaryStep.title = "Thank you."
                summaryStep.text = "We appreciate your time."
                steps += [summaryStep]

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

    private func constructNavigationRules(questions: [QuestionnaireItem], task: ORKNavigableOrderedTask) -> Void {

        let INVALID_OPERATOR = "This predicate has an invalid operator."

        for question in questions {
            if let enableWhen = question.enableWhen {
                switch enableWhen[0].answer {
                case .coding(let coding):
                    switch enableWhen[0].`operator`.value {
                    case .exists, .equal:
                        if let matchQuestion = question.enableWhen?[0].question.value?.string,
                           let matchValue = coding.code?.value?.string,
                           let thisQuestion = question.linkId.value?.string {
                            let matchingPattern = "^(?!\(matchValue)).*$"
                            let predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: ORKResultSelector(resultIdentifier: matchQuestion), matchingPattern: matchingPattern)
                            let rule = ORKPredicateSkipStepNavigationRule(resultPredicate: predicate)
                            task.setSkip(rule, forStepIdentifier: thisQuestion)
                        }
                    default:
                        print(INVALID_OPERATOR)
                    }
                case .boolean(let boolean):
                    if let booleanValue = boolean.value?.bool,
                       let thisQuestionId = question.linkId.value?.string,
                       let enableQuestionId = question.enableWhen?[0].question.value?.string {
                        switch enableWhen[0].`operator`.value {
                        case .equal:
                            let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: ORKResultSelector(resultIdentifier: enableQuestionId), expectedAnswer: !booleanValue)
                            let rule = ORKPredicateSkipStepNavigationRule(resultPredicate: predicate)
                            task.setSkip(rule, forStepIdentifier: thisQuestionId)
                        case .notEqual:
                            let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: ORKResultSelector(resultIdentifier: enableQuestionId), expectedAnswer: booleanValue)
                            let rule = ORKPredicateSkipStepNavigationRule(resultPredicate: predicate)
                            task.setSkip(rule, forStepIdentifier: thisQuestionId)
                        default:
                            print(INVALID_OPERATOR)
                        }
                    }
                case .date(_):
                    print("TODO")
                case .dateTime(_):
                    print("TODO")
                case .decimal(_):
                    print("TODO")
                case .integer(_):
                    print("TODO")
                case .quantity(_):
                    print("TODO")
                case .reference(_):
                    print("TODO")
                case .string(_):
                    print("TODO")
                case .time(_):
                    print("TODO")
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
