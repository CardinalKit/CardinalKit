//
//  QuestionnaireItem+ResearchKit.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import ModelsR4
import ResearchKit


extension Array where Element == QuestionnaireItem {
    /// Converts FHIR `QuestionnaireItems` (questions) to ResearchKit `ORKSteps`.
    /// - Parameters:
    ///   - title: A `String` that will be rendered above the questions by ResearchKit.
    ///   - valueSets: An array of `ValueSet` items containing sets of answer choices
    /// - Returns:An `Array` of ResearchKit `ORKSteps`.
    func fhirQuestionnaireItemsToORKSteps(title: String, valueSets: [ValueSet]) -> [ORKStep] {
        var surveySteps: [ORKStep] = []
        surveySteps.reserveCapacity(self.count)

        for question in self {
            guard let questionType = question.type.value,
                  !question.hidden else {
                continue
            }

            switch questionType {
            case QuestionnaireItemType.group:
                /// Converts multiple questions in a group into a ResearchKit form step
                if let groupStep = question.groupToORKFormStep(title: title, valueSets: valueSets) {
                    surveySteps.append(groupStep)
                }
            case QuestionnaireItemType.display:
                /// Creates a ResearchKit instruction step with the string to display
                if let instructionStep = question.displayToORKInstructionStep(title: title) {
                    surveySteps.append(instructionStep)
                }
            default:
                /// Converts individual questions to ResearchKit Question steps
                if let step = question.toORKQuestionStep(title: title, valueSets: valueSets) {
                    if let required = question.required?.value?.bool {
                        step.isOptional = !required
                    }
                    surveySteps.append(step)
                }
            }
        }

        return surveySteps
    }
}


extension QuestionnaireItem {
    /// Converts a FHIR `QuestionnaireItem` to a ResearchKit `ORKQuestionStep`.
    /// - Parameters:
    ///   - title: A `String` that will be displayed above the question when rendered by ResearchKit.
    ///   - valueSets: An array of `ValueSet` items containing sets of answer choices
    /// - Returns: An `ORKQuestionStep` object (a ResearchKit question step containing the above question).
    fileprivate func toORKQuestionStep(title: String, valueSets: [ValueSet]) -> ORKQuestionStep? {
        guard let identifier = linkId.value?.string else {
            return nil
        }

        let questionText = text?.value?.string ?? ""
        let answer = try? self.toORKAnswerFormat(valueSets: valueSets)
        return ORKQuestionStep(identifier: identifier, title: title, question: questionText, answer: answer)
    }

    /// Converts a FHIR QuestionnaireItem that contains a group of question items into a ResearchKit form (ORKFormStep).
    /// - Parameters:
    ///   - title: A String that will be displayed at the top of the form when rendered by ResearchKit.
    ///   - valueSets: An array of `ValueSet` items containing sets of answer choices
    /// - Returns: An ORKFormStep object (a ResearchKit form step containing all of the nested questions).
    fileprivate func groupToORKFormStep(title: String, valueSets: [ValueSet]) -> ORKFormStep? {
        guard let id = linkId.value?.string,
              let nestedQuestions = item else {
            return nil
        }

        let formStep = ORKFormStep(identifier: id)
        formStep.title = title
        formStep.text = text?.value?.string ?? ""
        var formItems = [ORKFormItem]()

        for question in nestedQuestions {
            guard let questionId = question.linkId.value?.string,
                  let questionText = question.text?.value?.string,
                  let answerFormat = try? question.toORKAnswerFormat(valueSets: valueSets) else {
                continue
            }

            let formItem = ORKFormItem(identifier: questionId, text: questionText, answerFormat: answerFormat)
            if let required = question.required?.value?.bool {
                formItem.isOptional = required
            }

            formItems.append(formItem)
        }

        formStep.formItems = formItems
        return formStep
    }

    /// Converts FHIR `QuestionnaireItem` display type to `ORKInstructionStep`
    /// - Parameters:
    ///   - title: A `String` to display at the top of the view rendered by ResearchKit.
    /// - Returns: A ResearchKit `ORKInstructionStep`.
    fileprivate func displayToORKInstructionStep(title: String) -> ORKInstructionStep? {
        guard let id = linkId.value?.string,
              let text = text?.value?.string else {
            return nil
        }

        let instructionStep = ORKInstructionStep(identifier: id)
        instructionStep.title = title
        instructionStep.detailText = text
        return instructionStep
    }

    /// Converts FHIR QuestionnaireItem answer types to the corresponding ResearchKit answer types (ORKAnswerFormat).
    /// - Parameter valueSets: An array of `ValueSet` items containing sets of answer choices
    /// - Returns: An object of type `ORKAnswerFormat` representing the type of answer this question accepts.
    // swiftlint:disable cyclomatic_complexity
    private func toORKAnswerFormat(valueSets: [ValueSet]) throws -> ORKAnswerFormat {
        switch type.value {
        case .boolean:
            return ORKBooleanAnswerFormat.booleanAnswerFormat()
        case .choice:
            let answerOptions = toORKTextChoice(valueSets: valueSets)
            guard !answerOptions.isEmpty else {
                throw FHIRToResearchKitConversionError.noOptions
            }
            return ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: answerOptions)
        case .date:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
        case .dateTime:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
        case .time:
            return ORKTimeOfDayAnswerFormat()
        case .decimal, .quantity:
            let answerFormat = ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: unit)
            answerFormat.maximumFractionDigits = maximumDecimalPlaces
            answerFormat.minimum = minValue
            answerFormat.maximum = maxValue
            return answerFormat
        case .integer:
            let answerFormat = ORKNumericAnswerFormat.integerAnswerFormat(withUnit: nil)
            answerFormat.minimum = minValue
            answerFormat.maximum = maxValue
            return answerFormat
        case .text, .string:
            let maximumLength = Int(maxLength?.value?.integer ?? 0)
            let answerFormat = ORKTextAnswerFormat(maximumLength: maximumLength)

            /// Applies a regular expression for validation, if defined
            if let validationRegularExpression = validationRegularExpression {
                answerFormat.validationRegularExpression = validationRegularExpression
                answerFormat.invalidMessage = validationMessage ?? "Invalid input"
            }

            return answerFormat
        default:
            return ORKTextAnswerFormat()
        }
    }

    /// Converts FHIR text answer choices to ResearchKit `ORKTextChoice`.
    /// - Parameter - valueSets: An array of `ValueSet` items containing sets of answer choices
    /// - Returns: An array of `ORKTextChoice` objects, each representing a textual answer option.
    private func toORKTextChoice(valueSets: [ValueSet]) -> [ORKTextChoice] {
        var choices: [ORKTextChoice] = []

        /// If the `QuestionnaireItem` has an `answerValueSet` defined which is a reference to a contained `ValueSet`,
        /// search the available `ValueSets`and, if a match is found, convert the options to `ORKTextChoice`
        if let answerValueSetURL = answerValueSet?.value?.url.absoluteString,
           answerValueSetURL.starts(with: "#") {
            let valueSet = valueSets.first { valueSet in
                if let valueSetID = valueSet.id?.value?.string {
                    return "#\(valueSetID)" == answerValueSetURL
                }
                return false
            }

            guard let answerOptions = valueSet?.compose?.include.first?.concept else {
                return choices
            }

            for option in answerOptions {
                guard let display = option.display?.value?.string,
                      let code = option.code.value?.string else {
                    continue
                }
                let valueCoding = [
                    "code": code,
                    "system": valueSet?.compose?.include.first?.system?.value?.url.absoluteString
                ]
                let choice = ORKTextChoice(text: display, value: valueCoding as NSSecureCoding & NSCopying & NSObjectProtocol)
                choices.append(choice)
            }
        } else {
            /// If the `QuestionnaireItem` has `answerOptions` defined instead, extract these options
            /// and convert them to `ORKTextChoice`
            guard let answerOptions = answerOption else {
                return choices
            }

            for option in answerOptions {
                guard case let .coding(coding) = option.value,
                      let display = coding.display?.value?.string,
                      let code = coding.code?.value?.string else {
                    continue
                }
                let valueCoding = [
                    "code": code,
                    "system": coding.system?.value?.url.absoluteString
                ]
                let choice = ORKTextChoice(text: display, value: valueCoding as NSSecureCoding & NSCopying & NSObjectProtocol)
                choices.append(choice)
            }
        }
        return choices
    }
}
