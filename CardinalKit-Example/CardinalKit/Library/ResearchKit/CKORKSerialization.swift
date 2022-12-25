//
//  CKORKSerialization.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 28/06/21.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit

// swiftlint:disable type_body_length function_body_length legacy_objc_type
class CKORKSerialization {
    /**
     Transform the result of the ResearchKit task into a Json, including the questions
     JSON-friendly.

     - Parameters:
     - result: original `ORKTaskResult`
     - task: original `ORKTask`

     - Returns: [String:Any] dictionary with ResearchKit results (Questions and answers)
     */
    // swiftlint:disable cyclomatic_complexity
    static func CKTaskAsJson(result: ORKTaskResult, task: ORKTask) throws -> [String: Any]? {
        let dictQuestionTypes = [
            "None",
            "Scale",
            "SingleChoice",
            "MultipleChoice",
            "MultiplePicker",
            "Decimal",
            "Integer",
            "Boolean",
            "Text",
            "Time of day",
            "DateTime",
            "Date",
            "TimeInterval",
            "Height",
            "Weight",
            "Location",
            "SES"
        ]

        var resultDict = [String: Any]()
        resultDict["startDate"] = result.startDate
        resultDict["endDate"] = result.endDate
        resultDict["identifier"] = result.identifier
        resultDict["taskRunUUID"] = result.taskRunUUID.uuidString
        resultDict["class"] = String(describing: type(of: result).self)
        
        var questionsDict = [Any]()
        if let resultSteps = result.results {
            for step in resultSteps {
                var stepDict = [String: Any]()
                stepDict["startDate"] = step.startDate
                stepDict["endDate"] = step.endDate
                stepDict["identifier"] = step.identifier
                stepDict["class"] = String(describing: type(of: step).self)

                if let taskStep = task.step?(withIdentifier: step.identifier) {
                    if let stepQuestion = taskStep as? ORKQuestionStep {
                        if let answerFormat = stepQuestion.answerFormat,
                           let question = stepQuestion.question {
                            let questionTypeValue = answerFormat.questionType.rawValue
                            let questionTypeText = dictQuestionTypes[questionTypeValue]
                            stepDict["questionType"] = questionTypeValue
                            stepDict["questionTypeText"] = questionTypeText
                            stepDict["Options"] = CKOptions(answerFormat: answerFormat)
                            stepDict["question"] = question
                        }
                    } else if let stepForm = taskStep as? ORKFormStep {
                        var formResults = [Any]()
                        if let formItems = stepForm.formItems {
                            for item in formItems {
                                if let answerFormat = item.answerFormat {
                                    if let questionResult = step as? ORKStepResult,
                                       let stepFormResults = (CKResults(results: questionResult, identifier: item.identifier) as? [[String: Any]]) {
                                        var stepFormTransformed = [[String: Any]]()
                                        for itemFormResult in stepFormResults {
                                            let questionTypeValue = answerFormat.questionType.rawValue
                                            let questionTypeText = dictQuestionTypes[questionTypeValue]
                                            var itemFormTransformed = itemFormResult
                                            itemFormTransformed["questionType"] = questionTypeValue
                                            itemFormTransformed["questionTypeText"] = questionTypeText
                                            itemFormTransformed["question"] = item.text ?? "No Question"
                                            itemFormTransformed["Options"] = CKOptions(answerFormat: answerFormat)
                                            stepFormTransformed.append(itemFormTransformed)
                                        }
                                        formResults += stepFormTransformed
                                    }
                                }
                            }
                        }
                        stepDict["results"] = formResults
                        questionsDict.append(stepDict)
                    } else if let stepWalking = taskStep as? ORKWalkingTaskStep {
                        stepDict["numberOfStepsPerLeg"] = stepWalking.numberOfStepsPerLeg
                    }
                    
                    if !(taskStep is ORKFormStep) {
                        if let results = step as? ORKStepResult {
                            stepDict["results"] = CKResults(results: results, identifier: step.identifier)
                        }
                        questionsDict.append(stepDict)
                    }
                }
            }
        }
        resultDict["results"] = questionsDict
        return resultDict
    }
    
    private static func CKOptions(answerFormat: ORKAnswerFormat) -> Any {
        switch answerFormat {
        case is ORKTextChoiceAnswerFormat:
            if let choicesFormat = answerFormat as? ORKTextChoiceAnswerFormat {
                return CKTextChoices(choices: choicesFormat.textChoices)
            }
        case is ORKScaleAnswerFormat:
            if let scaleFormat = answerFormat as? ORKScaleAnswerFormat {
                var result = [String: Any]()
                result["Max"] = scaleFormat.maximum
                result["Min"] = scaleFormat.minimum
                result["Step"] = scaleFormat.step
                result["MaxDescription"] = scaleFormat.maximumValueDescription
                result["MinDescription"] = scaleFormat.minimumValueDescription
                return result
            }
        case is ORKContinuousScaleAnswerFormat:
            if let scaleFormat = answerFormat as? ORKContinuousScaleAnswerFormat {
                var result = [String: Any]()
                result["Max"] = scaleFormat.maximum
                result["Min"] = scaleFormat.minimum
                result["MaxDescription"] = scaleFormat.maximumValueDescription
                result["MinDescription"] = scaleFormat.minimumValueDescription
                return result
            }
        case is ORKTextScaleAnswerFormat:
            if let textScaleFormat = answerFormat as? ORKTextScaleAnswerFormat {
                return CKTextChoices(choices: textScaleFormat.textChoices)
            }
        case is ORKValuePickerAnswerFormat:
            if let pickerFormat = answerFormat as? ORKValuePickerAnswerFormat {
                return CKTextChoices(choices: pickerFormat.textChoices)
            }
        case is ORKMultipleValuePickerAnswerFormat:
            if let multipleFormat = answerFormat as? ORKMultipleValuePickerAnswerFormat {
                var pickerChoices = [Any]()
                for picker in multipleFormat.valuePickers {
                    pickerChoices.append(CKTextChoices(choices: picker.textChoices))
                }
                return pickerChoices
            }
        case is ORKImageChoiceAnswerFormat:
            if let imageFormat = answerFormat as? ORKImageChoiceAnswerFormat {
                return CKImageChoices(choices: imageFormat.imageChoices)
            }
        case is ORKBooleanAnswerFormat:
            if let booleanFormat = answerFormat as? ORKBooleanAnswerFormat {
                var result = [String: Any]()
                result["NoText"] = booleanFormat.no
                result["YesText"] = booleanFormat.yes
                return result
            }
        default:
            return "NoOptions"
        }
        return "NoOptions"
    }
    
    private static func CKTextChoices(choices: [ORKTextChoice]) -> Any {
        var choicesDict = [Any]()
        for choice in choices {
            var result = [String: Any]()
            if let detailText = choice.detailText {
                result["detail"] = detailText
            }
            result["text"] = choice.text
            result["value"] = choice.value
            choicesDict.append(result)
        }
        return choicesDict
    }
    
    private static func CKImageChoices(choices: [ORKImageChoice]) -> Any {
        var choicesDict = [Any]()
        for choice in choices {
            var resultDict = [String: Any]()
            resultDict["image"] = choice.normalStateImage
            resultDict["text"] = choice.text
            resultDict["value"] = choice.value
            choicesDict.append(resultDict)
        }
        return choicesDict
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    private static func CKResults(results: ORKStepResult, identifier: String) -> Any {
        var response = [Any]()
        let result = results.result(forIdentifier: identifier)
        var answer = ""
        var type = ""

        switch result {
        case is ORKBooleanQuestionResult:
            if let ans = (result as? ORKBooleanQuestionResult)?.booleanAnswer {
                answer = String(ans.boolValue)
                type = String(describing: ORKBooleanQuestionResult.self)
            }
        case is ORKChoiceQuestionResult:
            if let answers = (result as? ORKChoiceQuestionResult)?.choiceAnswers {
                for answer in answers {
                    response.append(
                        [
                            "answer": answer.description,
                            "class": String(describing: ORKChoiceQuestionResult.self),
                            "identifier": identifier
                        ]
                    )
                }
                return response
            }
        case is ORKDateQuestionResult:
            if let ans = (result as? ORKDateQuestionResult)?.dateAnswer {
                answer = "\(ans)"
                type = String(describing: ORKDateQuestionResult.self)
            }
        case is ORKLocationQuestionResult:
            if let ans = (result as? ORKLocationQuestionResult)?.locationAnswer {
                answer = "\(ans)"
                type = String(describing: ORKLocationQuestionResult.self)
            }
        case is ORKScaleQuestionResult:
            if let ans = (result as? ORKScaleQuestionResult)?.scaleAnswer {
                answer = "\(ans)"
                type = String(describing: ORKScaleQuestionResult.self)
            }
        case is ORKMultipleComponentQuestionResult:
            if let ans = (result as? ORKMultipleComponentQuestionResult)?.componentsAnswer {
                answer = "\(ans)"
                type = String(describing: ORKMultipleComponentQuestionResult.self)
            }
        case is ORKNumericQuestionResult:
            if let ans = (result as? ORKNumericQuestionResult)?.numericAnswer {
                answer = "\(ans)"
                type = String(describing: ORKNumericQuestionResult.self)
            }
        case is ORKScaleQuestionResult:
            if let ans = (result as? ORKScaleQuestionResult)?.scaleAnswer {
                answer = "\(ans)"
                type = String(describing: ORKScaleQuestionResult.self)
            }
        case is ORKTextQuestionResult:
            if let ans = (result as? ORKTextQuestionResult)?.textAnswer {
                answer = "\(ans)"
                type = String(describing: ORKTextQuestionResult.self)
            }
        case is ORKTimeIntervalQuestionResult:
            if let ans = (result as? ORKTimeIntervalQuestionResult)?.intervalAnswer {
                answer = "\(ans)"
                type = String(describing: ORKTimeIntervalQuestionResult.self)
            }
        case is ORKTimeOfDayQuestionResult:
            if let ans = (result as? ORKTimeOfDayQuestionResult)?.dateComponentsAnswer {
                answer = "\(ans)"
                type = String(describing: ORKTimeOfDayQuestionResult.self)
            }
        case is ORKSESQuestionResult:
            if let ans = (result as? ORKSESQuestionResult)?.rungPicked {
                answer = "\(ans)"
                type = String(describing: ORKSESQuestionResult.self)
            }
        case is ORKFileResult:
            let fileUrl = (result as? ORKFileResult)?.fileURL?.absoluteString ?? "No Url"
            let urlParts = fileUrl.components(separatedBy: "/")
            type = String(describing: ORKFileResult.self)
            return(
                [
                    "identifier": identifier,
                    "fileURL": fileUrl,
                    "urlStorage": urlParts[urlParts.count - 1],
                    "class": type
                ]
            )
        case .none:
            if results.identifier == identifier {
                if let nResults = results.results {
                    for result in nResults {
                        response.append(CKResults(results: results, identifier: result.identifier))
                    }
                    return response
                }
            }
        default:
            let className = String(describing: result.self )
            return(
                [
                    "identifier": identifier,
                    "class": className,
                    "TODO": "classNotImplemented"
                ]
            )
        }
        return [
            "answer": answer,
            "class": type,
            "identifier": identifier
        ]
    }
    
    /**
     Transform the Json into a result of the ResearchKit
     JSON-friendly.

     - Parameters:
     - object: original `JSON`

     - Returns: ORKTaskResult  Research kit object ORKTaskResultt
     */
    
    static func taskResult(fromJSONObject object: [AnyHashable: Any]) -> ORKTaskResult {
        if let identifier = object["identifier"] as? String {
            let result = ORKTaskResult(taskIdentifier: identifier, taskRun: UUID(), outputDirectory: nil)
            let results = transformResults(fromJSONObject: object)
            result.results = results
            return result
        }
        return ORKTaskResult(taskIdentifier: "empty", taskRun: UUID(), outputDirectory: nil)
    }
    private static func getResult(fromJsonObject object: [AnyHashable: Any]) -> ORKResult {
        if let identifier = object["identifier"] as? String {
            if let type = object["class"] as? String {
                let answer = object["answer"] ?? "No Answer"
                switch type {
                case "ORKBooleanQuestionResult":
                    let result = ORKBooleanQuestionResult(identifier: identifier)
                    result.booleanAnswer = answer as? NSNumber
                    return result
                case "ORKChoiceQuestionResult":
                    let result = ORKChoiceQuestionResult(identifier: identifier)
                    var answers = [NSSecureCoding & NSCopying & NSObject]()
                    if let nAnswer = answer as? NSSecureCoding & NSCopying & NSObject {
                        answers.append(nAnswer)
                        result.choiceAnswers = answers
                        return result
                    }
                case  "ORKDateQuestionResult":
                    let result = ORKDateQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKLocationQuestionResult":
                    let result = ORKLocationQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKScaleQuestionResult":
                    let result = ORKScaleQuestionResult(identifier: identifier)
                    if let answer = answer as? Int {
                        result.answer = answer as any NSCopying & NSSecureCoding & NSObjectProtocol
                    }
                    if let answer = answer as? String {
                        result.answer = Int(answer) as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    }
                    return result
                case "ORKMultipleComponentQuestionResult":
                    let result = ORKMultipleComponentQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKNumericQuestionResult":
                    let result = ORKNumericQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKTextQuestionResult":
                    let result = ORKTextQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKTimeIntervalQuestionResult":
                    let result = ORKTimeIntervalQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKTimeOfDayQuestionResult":
                    let result = ORKTimeOfDayQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKSESQuestionResult":
                    let result = ORKSESQuestionResult(identifier: identifier)
                    result.answer = answer as? any NSCopying & NSSecureCoding & NSObjectProtocol
                    return result
                case "ORKTaskResult":
                    let result = ORKTaskResult(taskIdentifier: identifier, taskRun: UUID(), outputDirectory: nil)
                    result.results = transformResults(fromJSONObject: object)
                    return result
                case "ORKStepResult":
                    let result = ORKStepResult(identifier: identifier)
                    result.results = transformResults(fromJSONObject: object)
                    return result
                case "ORKFileResult":
                    let result = ORKFileResult(identifier: identifier)
                    let fileURL = object["fileURL"] ?? "NoUrl"
                    result.fileURL = URL(string: ( (fileURL as? String) ?? "NoUrl"))
                    return result
                default:
                    let result = ORKTaskResult(
                        taskIdentifier: identifier,
                        taskRun: UUID(),
                        outputDirectory: nil
                    )
                    result.results = transformResults(fromJSONObject: object)
                    return result
                }
            }
        }
        return ORKTaskResult(
            taskIdentifier: "empty",
            taskRun: UUID(),
            outputDirectory: nil
        )
    }
    
    private static func transformResults(fromJSONObject object: [AnyHashable: Any]) -> [ORKResult] {
        let newObject = object
        if let jsonResults = newObject["results"] as? NSArray {
            var results = [ORKResult]()
            for jsonResult in jsonResults {
                if let jsonAsDict = jsonResult as? [String: Any] {
                    results.append(getResult(fromJsonObject: jsonAsDict))
                }
            }
            return results
        }
        
        if let jsonResults = newObject["results"] as? [String: Any] {
            return [getResult(fromJsonObject: jsonResults)]
        }
        return [ORKResult]()
    }
}
