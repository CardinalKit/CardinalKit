//
//  TaskItem.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 10/08/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit
import SwiftUI

struct TaskItem:Hashable {
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        true
    }
    var order: String;
    var title:String;
    var subtitle:String;
    var imageName: String;
    var section: String;
    
    var image: UIImage?{
        return UIImage(named: imageName) ?? UIImage(systemName: "questionmark.square")
    }
    
    var questions:[String];
    
    func View()->some View{
        var steps = [ORKStep]()
        var questionAsObj:[[String:Any]] = []
        for question in questions{
            let data = question.data(using: .utf8)!
            do{
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
                {
                    questionAsObj.append(jsonArray)
                }
            }
            catch{
                print("bad Json")
            }
        }
        questionAsObj = questionAsObj.sorted(by: {a,b in
            if let order1 = a["order"] as? String,
               let order2 = b["order"] as? String{
                return Int(order1) ?? 1 < Int(order2) ?? 1
            }
            return true
        })
        
        
        for question in questionAsObj {
            if let step = QuestionToStep(data:question){
                steps+=[step]
            }
        }
        return AnyView(CKTaskViewController(tasks: ORKOrderedTask(identifier: title, steps: steps)))
    }
    
    private func QuestionToStep(data:[String:Any])->ORKStep?{
//        let textChoices = [
//            ORKTextChoice(text: "Yes, Limited A lot", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: "Yes, Limited A Little", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: "w, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: "w2, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: "w3, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol),
//
//        ]
//        let booleanAnswer = ORKSESAnswerFormat(topRungText: "top", bottomRungText: "botton")
//        let booleanQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: "In the past four weeks, did you feel limited in the kind of work that you can accomplish?", answer: booleanAnswer)
//        return booleanQuestionStep
            if let type = data["type"] as? String,
               let question = data["question"] as? String,
               let identifier = data["identifier"] as? String,
               let description = data["description"] as? String,
               let title = data["title"] as? String
               {
                switch type {
                case "MultipleChoice":
                    if let step = multipleChoiceQuestion(data: data){
                        return step
                    }
                    break;
                case "SingleChoice":
                    if let step = singleChoiceQuestion(data: data){
                        return step
                    }
                    break;
                case "Form":
                    if let step = formStep(data: data){
                        return step
                    }
                    break;
                case "Area","Text":
                    return ORKQuestionStep(identifier: identifier, title: title, question: question, answer: ORKTextAnswerFormat(maximumLength: type=="Text" ? 50:1000))
                case "Scale":
                    if let max = data["max"] as? String,
                       let min = data["min"] as? String,
                       let step = data["step"] as? String,
                       let maxValueDescription = data["maxValueDescription"] as? String,
                       let minValueDescription = data["minValueDescription"] as? String{
                        let vertical = data["vertical"] as? String ?? "false"
                        
                        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue:Int(max) ?? 5, minimumValue: Int(min) ?? 0, defaultValue: 3, step: Int(step) ?? 1, vertical: Bool(vertical) ?? false, maximumValueDescription: maxValueDescription, minimumValueDescription: minValueDescription)
                        
                        let healthScaleQuestionStep = ORKQuestionStep(identifier: identifier, title: title, question: question, answer: healthScaleAnswerFormat)
                        return healthScaleQuestionStep
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
                        
                        let healthScaleQuestionStep = ORKQuestionStep(identifier: identifier, title: title, question: question, answer: healthScaleAnswerFormat)
                        return healthScaleQuestionStep
                    }
                    break;
                case "TextScale":
                    if let options = data["options"] as? [[String:String]],
                       let defaultIndex = data["defaultIndex"] as? String
                    {
                        let ScaleAnswerFormat = ORKTextScaleAnswerFormat(textChoices: getTextChoices(data: options), defaultIndex: Int(defaultIndex) ?? 1)
                        return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ScaleAnswerFormat)
                    }
                    break;
                case "Picker":
                    if let options = data["options"] as? [[String:String]]
                    {
                        let PickerAnswerFormat = ORKValuePickerAnswerFormat(textChoices:getTextChoices(data: options))
                        return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: PickerAnswerFormat)
                    }
                    break;
                case "Numeric":
                    if let max = data["max"] as? String,
                       let min = data["min"] as? String,
                       let unit = data["unit"] as? String,
                       let maxFractionDigits = data["maxFractionDigits"] as? String
                    {
                        let NumericAnswerFormat = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle(rawValue: 1)!, unit: unit, minimum: min as! NSNumber?, maximum: max as! NSNumber?, maximumFractionDigits: maxFractionDigits as! NSNumber?)
                        return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: NumericAnswerFormat)
                    }
                    break;
                case "ImageChoice":
                    if let options = data["options"] as? [[String:String]]
                    {
                        let ImageAnswerFormat = ORKImageChoiceAnswerFormat(imageChoices: getImageChoices(data: options))
                        return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ImageAnswerFormat)
                    }
                    break;
                case "TimeOfDay":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKTimeOfDayAnswerFormat())
                case "Date":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    let answerFormat = ORKAnswerFormat.dateTime()
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: answerFormat)
                
                case "Boolean":
                    if let yesText = data["yesText"] as? String,
                       let noText = data["noText"] as? String{
                        let booleanAnswer = ORKBooleanAnswerFormat(yesString: yesText, noString: noText)
                        let booleanQuestionStep = ORKQuestionStep(identifier: identifier, title: title, question: question, answer: booleanAnswer)
                        return booleanQuestionStep
                    }
                    break;
                case "Email":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKEmailAnswerFormat())
                case "TimeInterval":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKTimeIntervalAnswerFormat())
                case "Height":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKHeightAnswerFormat())
                case "Weight":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKHeightAnswerFormat())
                case "Location":
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKLocationAnswerFormat())
                case "SES":
                    if let topText = data["topText"] as? String,
                       let bottomText = data["bottomText"] as? String{
                    return ORKQuestionStep(identifier: identifier,title: title, question: question, answer: ORKSESAnswerFormat(topRungText: topText, bottomRungText: bottomText))
                }
                case "Instruction":
                    let instructionStep = ORKInstructionStep(identifier: identifier)
                    instructionStep.title = title
                    instructionStep.text = description
                    return instructionStep
                case "Signature":
                    let signatureStep = ORKSignatureStep(identifier: identifier)
                    signatureStep.title = title
                    signatureStep.text = description
                    return signatureStep
                case "Summary":
                    let summaryStep = ORKCompletionStep(identifier: identifier)
                    summaryStep.title = title
                    summaryStep.text = description
                    return summaryStep
                default:
                    print("other \(type)")
                }
            }
        return nil
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
                if let formItem = formItem(data:_question){
                    steps+=[formItem]
                }
            }
            let formStep = ORKFormStep(identifier: identifier, title: title, text: description)
            formStep.formItems=steps
            return formStep
            
        }
        return nil
    }
    
    private func formItem(data:[String:Any])->ORKFormItem?{
        
        if let type = data["type"] as? String{
            switch type {
            case "MultipleChoice","SingleChoice":
                if let question = data["question"] as? String,
                   let identifier = data["identifier"] as? String,
                   let options = data["options"] as? [[String:String]]{
                    let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: type=="MultipleChoice" ? .multipleChoice: .singleChoice, textChoices: getTextChoices(data: options))
                    let formItem = ORKFormItem(identifier: identifier, text: question, answerFormat: textChoiceAnswerFormat)
                    return formItem
                }
                break;
            case "Area","Text":
                if let question = data["question"] as? String,
                   let identifier = data["identifier"] as? String{
                    let formItem = ORKFormItem(identifier: identifier, text: question, answerFormat: ORKAnswerFormat.textAnswerFormat(withMaximumLength: type=="Text" ? 50:1000))
                    formItem.showsProgress = true
                    return formItem
                }
                break;
            case "Scale":
                
                break;
            case "Boolean":
                break;
            case "Instruction":
                
                break;
            case "Signature":
                
                break;
            default:
                print("other \(type)")
            }
        }
        
        
        
        return nil
    }
    
    private func multipleChoiceQuestion(data:[String:Any]) -> ORKStep? {
        return stepQuestion(data: data, multiple: true)
    }
    
    private func singleChoiceQuestion(data:[String:Any])->ORKStep?{
        return stepQuestion(data: data, multiple: false)
    }
    
    private func stepQuestion(data:[String:Any],multiple:Bool)->ORKStep?{
        if let question = data["question"] as? String,
           let description = data["description"] as? String,
           let identifier = data["identifier"] as? String,
           let options = data["options"] as? [[String:String]]
        {
            let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: multiple ? .multipleChoice: .singleChoice, textChoices: getTextChoices(data: options))
            let step = ORKQuestionStep(identifier: identifier, title: description, question: question, answer: textChoiceAnswerFormat)
            return step
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
