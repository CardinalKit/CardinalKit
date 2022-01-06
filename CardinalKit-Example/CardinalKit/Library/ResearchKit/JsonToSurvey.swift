//
//  JsonToSurvey.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 8/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import ResearchKit

class JsonToSurvey {
    static let shared = JsonToSurvey();
    func GetSurvey(from jsonData:[[String : Any]], identifier:String) -> ORKOrderedTask{
        
        var steps = [ORKStep]()
        for question in jsonData {
            if let type = question["type"] as? String,
               let identifier = question["identifier"] as? String,
               let description = question["description"] as? String,
               let title = question["title"] as? String
            {
                let qs = question["question"] as? String ?? ""
                switch type {
                case "instruction":
                    let instructionStep = ORKInstructionStep(identifier: identifier)
                    instructionStep.title = title
                    instructionStep.text = description
                    steps+=[instructionStep]
                    break;
                case "signature":
                    let signatureStep = ORKSignatureStep(identifier: identifier)
                    signatureStep.title = title
                    signatureStep.text = description
                    steps+=[signatureStep]
                    break;
                case "summary":
                    let summaryStep = ORKCompletionStep(identifier: identifier)
                    summaryStep.title = title
                    summaryStep.text = description
                    steps+=[summaryStep]
                    break;
                    
                case "form":
                    if let step = formStep(data: question){
                        steps+=[step]
                    }
                    break;
                default:
                    if let step = QuestionToStep(data:question){
                        steps+=[ORKQuestionStep(identifier: identifier, title: title, question: qs, answer: step)]
                    }
                }
            }
        }
        return ORKOrderedTask(identifier: identifier, steps: steps)
    }
    
    private func formStep(data:[String:Any])->ORKStep? {
        if let _questions = data["questions"] as? [[String:Any]],
           let identifier = data["identifier"] as? String,
           let description = data["description"] as? String,
           let title = data["title"] as? String
        {
            var steps:[ORKFormItem] = []
            for _question in _questions.sorted(by: {a,b in
                if let order1 = a["order"] as? String,
                   let order2 = b["order"] as? String{
                    return Int(order1) ?? 1 < Int(order2) ?? 1
                }
                return true
            }){
                if let question = _question["question"] as? String,
                   let identifier = _question["identifier"] as? String{
                    if let formItem = QuestionToStep(data:_question){
                        steps+=[ORKFormItem(identifier: identifier, text: question, answerFormat: formItem)   ]
                    }
                }
            }
            let formStep = ORKFormStep(identifier: identifier, title: title, text: description)
            formStep.formItems=steps
            return formStep
            
        }
        return nil
    }
    
    private func QuestionToStep(data:[String:Any])->ORKAnswerFormat?{
            if let type = data["type"] as? String
               {
                
                switch type {
                case "multipleChoice":
                    if let step = multipleChoiceQuestion(data: data){
                        return step
                    }
                    break;
                case "singleChoice":
                    if let step = singleChoiceQuestion(data: data){
                        return step
                    }
                    break;
                case "area","text":
                    return ORKTextAnswerFormat(maximumLength: type=="Text" ? 50:1000)
                case "scale":
                    if let max = data["max"] as? String,
                       let min = data["min"] as? String,
                       let step = data["step"] as? String,
                       let maxValueDescription = data["maxValueDescription"] as? String,
                       let minValueDescription = data["minValueDescription"] as? String{
                        let vertical = data["vertical"] as? String ?? "false"
                        
                        let intMax = Int(max) ?? 5
                        var intMin = Int(min) ?? 0
                        var intStep = Int(step) ?? 1
                                                
                        if intMin > intMax {
                            intMin = intMax - 1
                        }
                        
                        let difference = intMax-intMin
                        
                        if difference < intStep {
                            intStep=difference
                        }
                        
                        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue:intMax, minimumValue: intMin, defaultValue: 3, step: intStep, vertical: Bool(vertical) ?? false, maximumValueDescription: maxValueDescription, minimumValueDescription: minValueDescription)
                        
                        return healthScaleAnswerFormat
                    }
                    break;
                case "continiousScale":
                    if let max = data["max"] as? String,
                       let min = data["min"] as? String,
                       let defaultV = data["default"] as? String,
                       let maxValueDescription = data["maxValueDescription"] as? String,
                       let minValueDescription = data["minValueDescription"] as? String
                    {
                        let maxFractionDigits = data["maxFractionDigits"]  as? String ?? "1"
                        let vertical = data["vertical"] as? String ?? "false"
                        
                        let healthScaleAnswerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: Double(max) ?? 5.0, minimumValue: Double(min) ?? 1.0, defaultValue: Double(defaultV) ?? 3.0, maximumFractionDigits: Int(maxFractionDigits) ?? 1, vertical: Bool(vertical) ?? false, maximumValueDescription: maxValueDescription, minimumValueDescription: minValueDescription)
                        
                        return healthScaleAnswerFormat
                    }
                    break;
                case "textScale":
                    if let options = data["options"] as? [[String:String]],
                       let defaultIndex = data["defaultIndex"] as? String
                    {
                        let ScaleAnswerFormat = ORKTextScaleAnswerFormat(textChoices: getTextChoices(data: options), defaultIndex: Int(defaultIndex) ?? 1)
                        return ScaleAnswerFormat
                    }
                    break;
                case "picker":
                    if let options = data["options"] as? [[String:String]]
                    {
                        let PickerAnswerFormat = ORKValuePickerAnswerFormat(textChoices:getTextChoices(data: options))
                        return PickerAnswerFormat
                    }
                    break;
                case "numeric":
                    if let max = data["max"] as? String,
                       let min = data["min"] as? String,
                       let unit = data["unit"] as? String,
                       let maxFractionDigits = data["maxFractionDigits"] as? String
                    {
                        let max = Int(max) ?? 5
                        let min = Int(min) ?? 1
                        let maxFractionDigits = Int(maxFractionDigits) ?? 2
                        let NumericAnswerFormat = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle(rawValue: 1)!, unit: unit, minimum: Int(min) as NSNumber?, maximum: Int(max) as NSNumber?, maximumFractionDigits: maxFractionDigits as NSNumber?)
                        return NumericAnswerFormat
                    }
                    break;
                case "IimageChoice":
                    if let options = data["options"] as? [[String:String]]
                    {
                        let ImageAnswerFormat = ORKImageChoiceAnswerFormat(imageChoices: getImageChoices(data: options))
                        return ImageAnswerFormat
                    }
                    break;
                case "timeOfDay":
                    return ORKTimeOfDayAnswerFormat()
                case "date":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    let answerFormat = ORKAnswerFormat.dateTime()
                    return answerFormat
                
                case "boolean":
                    if let yesText = data["yesText"] as? String,
                       let noText = data["noText"] as? String{
                        let booleanAnswer = ORKBooleanAnswerFormat(yesString: yesText, noString: noText)
                        return booleanAnswer
                    }
                    break;
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
                       let bottomText = data["bottomText"] as? String{
                    return ORKSESAnswerFormat(topRungText: topText, bottomRungText: bottomText)
                }
               
                default:
                    print("No Type")
                }
            }
        return nil
    }
    
    private func multipleChoiceQuestion(data:[String:Any]) -> ORKAnswerFormat? {
        return stepQuestion(data: data, multiple: true)
    }
    
    private func singleChoiceQuestion(data:[String:Any])->ORKAnswerFormat?{
        return stepQuestion(data: data, multiple: false)
    }
    
    private func stepQuestion(data:[String:Any],multiple:Bool)->ORKAnswerFormat?{
        if let options = data["options"] as? [[String:String]],
           options.count>0,
           options[0]["text"] != nil
        {
            let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: multiple ? .multipleChoice: .singleChoice, textChoices: getTextChoices(data: options))
            return textChoiceAnswerFormat
        }
        return nil
    }
    
    private func getTextChoices(data:[[String:String]])->[ORKTextChoice]{
        var textChoices:[ORKTextChoice] = []
        for option in data{
            if let text = option["text"],
               let value = option["value"]{
                textChoices+=[
                    ORKTextChoice(text: text, value: value as NSCoding & NSCopying & NSObjectProtocol)
                ]
            }
        }
        return textChoices
    }
    
    private func getImageChoices(data:[[String:String]])->[ORKImageChoice]{
        var imageChoicer:[ORKImageChoice] = []
        for option in data{
            if let text = option["text"],
               let value = option["value"]{
                imageChoicer+=[
                    ORKImageChoice(normalImage: nil, selectedImage: nil, text: text, value: value as NSCoding & NSCopying & NSObjectProtocol)
                ]
            }
        }
        return imageChoicer
    }
}



