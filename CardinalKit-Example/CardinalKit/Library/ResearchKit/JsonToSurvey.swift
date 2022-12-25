//
//  JsonToSurvey.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 8/09/21.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit

class JsonToSurvey {
    static let shared = JsonToSurvey()
    
    func getSurvey(from jsonData: [[String: Any]], identifier: String) -> ORKOrderedTask {
        var steps = [ORKStep]()
        
        for question in jsonData {
            if let type = question["type"] as? String,
               let identifier = question["identifier"] as? String,
               let description = question["description"] as? String,
               let title = question["title"] as? String {
                let questionItem = question["question"] as? String ?? ""
                switch type {
                case "instruction":
                    let instructionStep = ORKInstructionStep(identifier: identifier)
                    instructionStep.title = title
                    instructionStep.text = description
                    steps += [instructionStep]
                case "signature":
                    let signatureStep = ORKSignatureStep(identifier: identifier)
                    signatureStep.title = title
                    signatureStep.text = description
                    steps += [signatureStep]
                case "summary":
                    let summaryStep = ORKCompletionStep(identifier: identifier)
                    summaryStep.title = title
                    summaryStep.text = description
                    steps += [summaryStep]
                case "form":
                    if let step = formStep(data: question) {
                        steps += [step]
                    }
                default:
                    if let step = questionToStep(data: question) {
                        let questionStep = ORKQuestionStep(
                            identifier: identifier,
                            title: title,
                            question: questionItem,
                            answer: step
                        )
                        steps += [questionStep]
                    }
                }
            }
        }
        return ORKOrderedTask(identifier: identifier, steps: steps)
    }
    
    private func formStep(data: [String: Any]) -> ORKStep? {
        if let questionsArr = data["questions"] as? [[String: Any]],
           let identifier = data["identifier"] as? String,
           let description = data["description"] as? String,
           let title = data["title"] as? String {
            var steps: [ORKFormItem] = []
            for questionItem in questionsArr.sorted(by: { first, second in
                if let order1 = first["order"] as? String,
                   let order2 = second["order"] as? String {
                    return Int(order1) ?? 1 < Int(order2) ?? 1
                }
                return true
            }) {
                if let question = questionItem["question"] as? String,
                   let identifier = questionItem["identifier"] as? String {
                    if let formItem = questionToStep(data: questionItem) {
                        let item = ORKFormItem(
                            identifier: identifier,
                            text: question,
                            answerFormat: formItem
                        )
                        steps += [item]
                    }
                }
            }
            let formStep = ORKFormStep(
                identifier: identifier,
                title: title,
                text: description
            )
            formStep.formItems = steps
            return formStep
        }
        return nil
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    private func questionToStep(data: [String: Any]) -> ORKAnswerFormat? {
        if let type = data["type"] as? String {
            switch type {
            case "multipleChoice":
                if let step = multipleChoiceQuestion(data: data) {
                    return step
                }
            case "singleChoice":
                if let step = singleChoiceQuestion(data: data) {
                    return step
                }
            case "area", "text":
                return ORKTextAnswerFormat(maximumLength: type == "Text" ? 50:1000)
            case "scale":
                if let max = data["max"] as? String,
                   let min = data["min"] as? String,
                   let step = data["step"] as? String,
                   let maxValueDescription = data["maxValueDescription"] as? String,
                   let minValueDescription = data["minValueDescription"] as? String {
                    let vertical = data["vertical"] as? String ?? "false"
                    
                    let intMax = Int(max) ?? 5
                    var intMin = Int(min) ?? 0
                    var intStep = Int(step) ?? 1
                    
                    if intMin > intMax {
                        intMin = intMax - 1
                    }
                    
                    let difference = intMax - intMin
                    
                    if difference < intStep {
                        intStep = difference
                    }
                    
                    let healthScaleAnswerFormat = ORKAnswerFormat.scale(
                        withMaximumValue: intMax,
                        minimumValue: intMin,
                        defaultValue: 3,
                        step: intStep,
                        vertical: Bool(vertical) ?? false,
                        maximumValueDescription: maxValueDescription,
                        minimumValueDescription: minValueDescription
                    )
                    
                    return healthScaleAnswerFormat
                }
            case "continuousScale":
                if let max = data["max"] as? String,
                   let min = data["min"] as? String,
                   let defaultV = data["default"] as? String,
                   let maxValueDescription = data["maxValueDescription"] as? String,
                   let minValueDescription = data["minValueDescription"] as? String {
                    let maxFractionDigits = data["maxFractionDigits"]  as? String ?? "1"
                    let vertical = data["vertical"] as? String ?? "false"
                    
                    let healthScaleAnswerFormat = ORKAnswerFormat.continuousScale(
                        withMaximumValue: Double(max) ?? 5.0,
                        minimumValue: Double(min) ?? 1.0,
                        defaultValue: Double(defaultV) ?? 3.0,
                        maximumFractionDigits: Int(maxFractionDigits) ?? 1,
                        vertical: Bool(vertical) ?? false,
                        maximumValueDescription: maxValueDescription,
                        minimumValueDescription: minValueDescription
                    )
                    return healthScaleAnswerFormat
                }
            case "textScale":
                if let options = data["options"] as? [[String: String]],
                   let defaultIndex = data["defaultIndex"] as? String {
                    return ORKTextScaleAnswerFormat(
                        textChoices: getTextChoices(data: options),
                        defaultIndex: Int(defaultIndex) ?? 1
                    )
                }
            case "picker":
                if let options = data["options"] as? [[String: String]] {
                    return ORKValuePickerAnswerFormat(textChoices: getTextChoices(data: options))
                }
            case "numeric":
                if let max = data["max"] as? String,
                   let min = data["min"] as? String,
                   let unit = data["unit"] as? String,
                   let maxFractionDigits = data["maxFractionDigits"] as? String {
                    let max = Int(max) ?? 5
                    let min = Int(min) ?? 1
                    let maxFractionDigits = Int(maxFractionDigits) ?? 2
                    let numericAnswerFormat = ORKNumericAnswerFormat(
                        style: .decimal,
                        unit: unit,
                        minimum: Int(min) as NSNumber?,
                        maximum: Int(max) as NSNumber?,
                        maximumFractionDigits: maxFractionDigits as NSNumber?
                    )
                    return numericAnswerFormat
                }
            case "imageChoice":
                if let options = data["options"] as? [[String: String]] {
                    return ORKImageChoiceAnswerFormat(imageChoices: getImageChoices(data: options))
                }
            case "timeOfDay":
                return ORKTimeOfDayAnswerFormat()
            case "date":
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                let answerFormat = ORKAnswerFormat.dateTime()
                return answerFormat
            case "boolean":
                if let yesText = data["yesText"] as? String,
                   let noText = data["noText"] as? String {
                    return ORKBooleanAnswerFormat(yesString: yesText, noString: noText)
                }
            case "email":
                return ORKEmailAnswerFormat()
            case "timeInterval":
                return ORKTimeIntervalAnswerFormat()
            case "height":
                return ORKHeightAnswerFormat()
            case "weight":
                return ORKHeightAnswerFormat()
            case "location":
                return  ORKLocationAnswerFormat()
            case "socioeconomic":
                if let topText = data["topText"] as? String,
                   let bottomText = data["bottomText"] as? String {
                    return ORKSESAnswerFormat(topRungText: topText, bottomRungText: bottomText)
                }
            default:
                print("No Type")
            }
        }
        return nil
    }
    
    private func multipleChoiceQuestion(data: [String: Any]) -> ORKAnswerFormat? {
        stepQuestion(data: data, multiple: true)
    }
    
    private func singleChoiceQuestion(data: [String: Any]) -> ORKAnswerFormat? {
        stepQuestion(data: data, multiple: false)
    }
    
    private func stepQuestion(data: [String: Any], multiple: Bool) -> ORKAnswerFormat? {
        if let options = data["options"] as? [[String: String]],
           !options.isEmpty,
           options[0]["text"] != nil {
            let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(
                with: multiple ? .multipleChoice: .singleChoice,
                textChoices: getTextChoices(data: options)
            )
            return textChoiceAnswerFormat
        }
        return nil
    }
    
    private func getTextChoices(data: [[String: String]]) -> [ORKTextChoice] {
        var textChoices: [ORKTextChoice] = []
        for option in data {
            if let text = option["text"],
               let value = option["value"] {
                let choice = ORKTextChoice(
                    text: text,
                    value: value as NSSecureCoding & NSCopying & NSObjectProtocol
                )
                textChoices += [choice]
            }
        }
        return textChoices
    }
    
    private func getImageChoices(data: [[String: String]]) -> [ORKImageChoice] {
        var imageChoice: [ORKImageChoice] = []
        for option in data {
            if let text = option["text"],
               let value = option["value"] {
                let choice = ORKImageChoice(
                    normalImage: nil,
                    selectedImage: nil,
                    text: text,
                    value: value as NSSecureCoding & NSCopying & NSObjectProtocol
                )
                imageChoice += [choice]
            }
        }
        return imageChoice
    }
}
