//
//  CK_ORKSerialization.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 28/06/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ResearchKit

class CK_ORKSerialization{
    /**
     Transform the result of the ResearchKit task into a Json, including the questions
     JSON-friendly.

     - Parameters:
        - result: original `ORKTaskResult`
        - task: original `ORKTask`
            
     - Returns: [String:Any] dictionary with ResearchKit results (Questions and answers)
    */
    static func CKTaskAsJson(result: ORKTaskResult, task: ORKTask) throws -> [String:Any]?{
        let dictQuestionTypes = ["None","Scale","SingleChoice","MultipleChoice","MultiplePicker","Decimal", "Integer","Boolean","Text","Time of day","DateTime","Date","TimeInterval","Height","Weight","Location","SES"]
        var Result = [String:Any]()
        Result["startDate"] = result.startDate
        Result["endDate"] = result.endDate
        Result["identifier"] = result.identifier
        Result["taskRunUUID"]=result.taskRunUUID.uuidString
        Result["class"] = String(describing: type(of: result).self)
        print(String(describing: type(of: result).self))
        
        var QuestionsDict = [Any]()
        if let resultSteps = result.results{
            for step in resultSteps{
                var StepDict = [String:Any]()
                StepDict["startDate"] = step.startDate
                StepDict["endDate"] = step.endDate
                StepDict["identifier"] = step.identifier
                StepDict["class"] = String(describing: type(of: step).self)
                if let taskStep = task.step?(withIdentifier: step.identifier){
                    if let stepQuestion = taskStep as? ORKQuestionStep{
                        let questionTypeValue = stepQuestion.answerFormat!.questionType.rawValue
                        let questionTypeText = dictQuestionTypes[questionTypeValue]
                        StepDict["questionType"] = questionTypeValue
                        StepDict["questionTypeText"] = questionTypeText
                        StepDict["question"] = stepQuestion.question!
                        StepDict["Options"] = CKOptions(answerFormat:stepQuestion.answerFormat!)
                    }
                   else if let stepForm = taskStep as? ORKFormStep{
                        var FormResults = [Any]()
                        for item in stepForm.formItems!{
                            if let answerFormat = item.answerFormat{
                            
                            if let questionResult = step as? ORKStepResult{
                                let stepFormResults = (CKResults(results: questionResult, identifier: item.identifier) as! [[String:Any]])
                                var stepFormTransformed = [[String:Any]]()
                                for itemFormResult in stepFormResults{
                                    let questionTypeValue = answerFormat.questionType.rawValue
                                    let questionTypeText = dictQuestionTypes[questionTypeValue]
                                    var itemFormTransformed = itemFormResult
                                    itemFormTransformed["questionType"] = questionTypeValue
                                    itemFormTransformed["questionTypeText"] = questionTypeText
                                    itemFormTransformed["question"] = item.text!
                                    itemFormTransformed["Options"] = CKOptions(answerFormat:answerFormat)
                                    stepFormTransformed.append(itemFormTransformed)
                                }
                                
                                FormResults+=stepFormTransformed
                            }
                            }
                        }
                        StepDict["results"]=FormResults
                        QuestionsDict.append(StepDict)
                    }
                    else if let stepWalking = taskStep as? ORKWalkingTaskStep{
                        StepDict["numberOfStepsPerLeg"] = stepWalking.numberOfStepsPerLeg
                    }
                    
                    if !(taskStep is ORKFormStep){
                        if let Results = step as? ORKStepResult{
                            StepDict["results"] = CKResults(results: Results, identifier: step.identifier)
                        }
                        QuestionsDict.append(StepDict)
                   }
                    
                   
                }
            }
        }
        Result["results"] = QuestionsDict
        return Result
    }
    
    private static func CKOptions(answerFormat: ORKAnswerFormat)->Any{
        switch answerFormat {
        case is ORKTextChoiceAnswerFormat:
            let choicesFormat = answerFormat as! ORKTextChoiceAnswerFormat
            return CKTextChoices(choices: choicesFormat.textChoices)
        case is ORKScaleAnswerFormat:
            let scaleFormat = answerFormat as! ORKScaleAnswerFormat
            var Result = [String:Any]()
            Result["Max"] = scaleFormat.maximum
            Result["Min"] = scaleFormat.minimum
            Result["Step"] = scaleFormat.step
            Result["MaxDescription"] = scaleFormat.maximumValueDescription
            Result["MinDescription"] = scaleFormat.minimumValueDescription
            return Result
        case is ORKContinuousScaleAnswerFormat:
            let scaleFormat = answerFormat as! ORKContinuousScaleAnswerFormat
            var Result = [String:Any]()
            Result["Max"] = scaleFormat.maximum
            Result["Min"] = scaleFormat.minimum
            Result["MaxDescription"] = scaleFormat.maximumValueDescription
            Result["MinDescription"] = scaleFormat.minimumValueDescription
            return Result
        case is ORKTextScaleAnswerFormat:
            let textScaleFormat = answerFormat as! ORKTextScaleAnswerFormat
            return CKTextChoices(choices: textScaleFormat.textChoices)
        case is ORKValuePickerAnswerFormat:
            let pickerFormat = answerFormat as! ORKValuePickerAnswerFormat
            return CKTextChoices(choices: pickerFormat.textChoices)
        case is ORKMultipleValuePickerAnswerFormat:
            let multipleFormat = answerFormat as! ORKMultipleValuePickerAnswerFormat
            var pickerChoices = [Any]()
            for picker in multipleFormat.valuePickers{
                pickerChoices.append(CKTextChoices(choices: picker.textChoices))
            }
            return pickerChoices
        case is ORKImageChoiceAnswerFormat:
            let imageFormat = answerFormat as! ORKImageChoiceAnswerFormat
            return CKImageChoices(choices: imageFormat.imageChoices)
        case is ORKBooleanAnswerFormat:
            let booleanFormat = answerFormat as! ORKBooleanAnswerFormat
            var Result = [String:Any]()
            Result["NoText"] = booleanFormat.no
            Result["YesText"] = booleanFormat.yes
            return Result
        default:
            return "NoOptions"
        }
    }
    
    private static func CKTextChoices(choices:[ORKTextChoice])->Any{
        var ChoicesDict = [Any]()
        for choice in choices{
            var Result = [String:Any]()
            if let detailText = choice.detailText{
                Result["detail"] = detailText
            }
            Result["text"] = choice.text
            Result["value"] = choice.value
            ChoicesDict.append(Result)
        }
        return ChoicesDict
    }
    
    private static func CKImageChoices(choices:[ORKImageChoice])->Any{
        var ChoicesDict = [Any]()
        for choice in choices{
            var Result = [String:Any]()
            Result["image"] =  choice.normalStateImage
            Result["text"] = choice.text
            Result["value"] = choice.value
            ChoicesDict.append(Result)
        }
        return ChoicesDict
    }

    private static func CKResults(results: ORKStepResult, identifier: String) -> Any{
        var response = [Any]()
        let result = results.result(forIdentifier: identifier)
        var answer:Any = ""
        var _class = ""
        switch result {
            case is ORKBooleanQuestionResult:
                answer=(result as! ORKBooleanQuestionResult).booleanAnswer!.boolValue
                _class = String(describing: ORKBooleanQuestionResult.self)
            case is ORKChoiceQuestionResult:
                for answer in (result as! ORKChoiceQuestionResult).choiceAnswers!{
                    response.append(["answer":answer.description,"class":String(describing: ORKChoiceQuestionResult.self),"identifier":identifier])
                }
                return response
            case is ORKDateQuestionResult:
                answer=(result as! ORKDateQuestionResult).dateAnswer!
                _class = String(describing: ORKDateQuestionResult.self)
            case is ORKLocationQuestionResult:
                answer=(result as! ORKLocationQuestionResult).locationAnswer!;
                _class = String(describing: ORKLocationQuestionResult.self)
            case is ORKScaleQuestionResult:
                answer=(result as! ORKScaleQuestionResult).scaleAnswer!;
                _class = String(describing: ORKScaleQuestionResult.self)
            case is ORKMultipleComponentQuestionResult:
                answer=((result as! ORKMultipleComponentQuestionResult).componentsAnswer!);
                _class = String(describing: ORKMultipleComponentQuestionResult.self)
            case is ORKNumericQuestionResult:
                answer=((result as! ORKNumericQuestionResult).numericAnswer!);
                _class = String(describing: ORKNumericQuestionResult.self)
            case is ORKScaleQuestionResult:
                answer=((result as! ORKScaleQuestionResult).scaleAnswer!);
                _class = String(describing: ORKScaleQuestionResult.self)
            case is ORKTextQuestionResult:
                answer=((result as! ORKTextQuestionResult).textAnswer!);
                _class = String(describing: ORKTextQuestionResult.self)
            case is ORKTimeIntervalQuestionResult:
                answer=((result as! ORKTimeIntervalQuestionResult).intervalAnswer!);
                _class = String(describing: ORKTimeIntervalQuestionResult.self)
            case is ORKTimeOfDayQuestionResult:
                answer=((result as! ORKTimeOfDayQuestionResult).dateComponentsAnswer!);
                _class = String(describing: ORKTimeOfDayQuestionResult.self)
            case is ORKSESQuestionResult:
                answer=((result as! ORKSESQuestionResult).rungPicked!);
                _class = String(describing: ORKSESQuestionResult.self)
            case is ORKFileResult:
                let fileUrl = (result as! ORKFileResult).fileURL?.absoluteString ?? "No Url"
                let urlParts = fileUrl.components(separatedBy: "/")
                _class = String(describing: ORKFileResult.self)
                return(["identifier":identifier,"fileURL":(result as! ORKFileResult).fileURL?.absoluteString ?? "No Url","urlStorage":urlParts[urlParts.count-1],"class":_class])
                
            case .none:
                if results.identifier == identifier{
                    for result in results.results!{
                        response.append(CKResults(results: results, identifier: result.identifier))
                    }
                    return response
                }
                break;
            default:
                return(["identifier":identifier,"class":String(describing: result!.self),"TODO":"classNotImplemented"]);
        }
        return ["answer":answer,"class":_class,"identifier":identifier]
    }
    
    /**
     Transform the Json into a result of the ResearchKit
     JSON-friendly.

     - Parameters:
        - object: original `JSON`
            
     - Returns: ORKTaskResult  Research kit object ORKTaskResultt
    */
    
    static func TaskResult(fromJSONObject object: [AnyHashable : Any])-> ORKTaskResult {
        
        if let identifier = object["identifier"] as? String{
            let result = ORKTaskResult(identifier: identifier)
            let results = TransformResults(fromJSONObject: object)
            result.results=results
            return result
        }
        return ORKTaskResult()
    }
    private static func GetResult(fromJsonObject object: [AnyHashable : Any])-> ORKResult {
        if let identifier = object["identifier"] as? String{
            if let _class = object["class"] as? String{
                let answer = object["answer"] ?? "No Answer"
                switch _class {
                    case "ORKBooleanQuestionResult":
                        let result = ORKBooleanQuestionResult(identifier: identifier)
                        result.booleanAnswer = (answer as? NSNumber)
                        return result
                    case "ORKChoiceQuestionResult":
                        let result = ORKChoiceQuestionResult(identifier: identifier)
                        var answers = [NSCoding&NSCopying&NSObject]()
                        answers.append(answer as! NSCoding&NSCopying&NSObject)
                        result.choiceAnswers = answers
                        return result
                    case  "ORKDateQuestionResult":
                        let result = ORKDateQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKLocationQuestionResult":
                        let result = ORKLocationQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKScaleQuestionResult":
                        let result = ORKScaleQuestionResult(identifier: identifier)
                        result.answer = answer
                        return result
                    case "ORKMultipleComponentQuestionResult":
                        let result = ORKMultipleComponentQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKNumericQuestionResult":
                        let result = ORKNumericQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKTextQuestionResult":
                        let result = ORKTextQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKTimeIntervalQuestionResult":
                        let result = ORKTimeIntervalQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKTimeOfDayQuestionResult":
                        let result = ORKTimeOfDayQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKSESQuestionResult":
                        let result = ORKSESQuestionResult(identifier: identifier)
                        result.answer=answer
                        return result
                    case "ORKTaskResult":
                        let result = ORKTaskResult(identifier: identifier)
                        result.results=TransformResults(fromJSONObject: object)
                        return result
                    case "ORKStepResult":
                        let result = ORKStepResult(identifier: identifier)
                        result.results=TransformResults(fromJSONObject: object)
                        return result
                    case "ORKFileResult":
                        let result = ORKFileResult(identifier: identifier)
                        let fileURL = object["fileURL"] ?? "NoUrl"
                        result.fileURL = URL(string: fileURL as! String)
                        return result
                    default:
                        print("no class in cases")
                        print(_class)
                        let result = ORKTaskResult(identifier: identifier)
                        result.results=TransformResults(fromJSONObject: object)
                        return result
                }
            }
            }
        return ORKResult()
    }
    
    private static func TransformResults(fromJSONObject object: [AnyHashable : Any])-> [ORKResult] {
        let newObject = object
        if let JsonResults = newObject["results"] as? NSArray{
            var _results = [ORKResult]()
            for JsonResult in JsonResults{
                if let JsonAsDict = JsonResult as? [String:Any]{
                    _results.append(GetResult(fromJsonObject: JsonAsDict))
                }
            }
            return _results
        }
        
        if let JsonResults = newObject["results"] as? [String:Any]{
            return [GetResult(fromJsonObject: JsonResults)]
        }
        return [ORKResult]()
    }
}
