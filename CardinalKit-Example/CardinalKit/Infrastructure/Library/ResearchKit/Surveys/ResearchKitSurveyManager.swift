//
//  SurveyManager.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CardinalKit
import SwiftUI
import ResearchKit

class ResearchKitSurveyManager:SurveyManager {
    public func getSurveyCloudItems(onCompletion: @escaping ([TaskItem]) -> Void) {
        guard let surveyCollection = CKStudyUser.shared.surveysCollection else {
            onCompletion([])
            return
        }
        var AllItems=[TaskItem]()
        CKApp.requestData(route: surveyCollection,onCompletion: {(results) in
            if let results = results as? [String:Any]{
                var counter=results.count
                for (id, data) in results {
                    CKApp.requestData(route: surveyCollection+"\(id)/questions/", onCompletion: {
                        (surveyResult) in
                        if let surveyResult = surveyResult as? [String:Any]{
                            var deleted = false
                            var identifier = ""
                            var title=""
                            var subtitle=""
                            var imageName = ""
                            var section = ""
                            var questions:[String] = []
                            var order = "1"
                            if let data = data as? [String:Any],
                               let _identifier=data["identifier"] as? String{
                                title = data["title"] as? String ?? "NoTitle"
                                subtitle = data["subtitle"] as? String ?? "NoSubTitle"
                                imageName = data["image"] as? String ?? "NoImage"
                                section = data["section"] as? String ?? "NoSection"
                                order = data["order"] as? String ?? "1"
                                deleted = data["deleted"] as? Bool ?? false
                                identifier = _identifier
                            }
                        
                            for (_, question) in surveyResult{
                               if let question = question as? [String:Any]{
                                   do{
                                       let jsonData = try JSONSerialization.data(withJSONObject: question, options: .prettyPrinted)
                                       let convertedString = String(data: jsonData, encoding: String.Encoding.utf8)
                                       if let stringData:String = convertedString{
                                           questions.append(stringData)
                                       }
                                   }
                                   catch{
                                       print(error)
                                   }
                               }
                           }
                           if questions.count>0 && !deleted{
                               let taskitem: TaskItem = TaskItem(order:order, title: title, subtitle:subtitle, image: imageName, section: section, taskType: .custom, tasks: self.transformQuestionsToOrderedTask(questions: questions, identifier: identifier))
                               AllItems.append(taskitem)
                           }
                       }

                       counter-=1
                       if(counter<=0){
                           AllItems=AllItems.sorted(by: {a,b in return a.order<b.order})
                        onCompletion(AllItems)
                       }
                    })
                }
            }
        })
        
        onCompletion(AllItems)
        
    }
    
    func transformQuestionsToOrderedTask(questions:[String], identifier:String) -> ORKOrderedTask{
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
        return JsonToSurvey.shared.GetSurvey(from: questionAsObj,identifier: identifier)
    }
    
}
