//
//  CkResearchSurveysManager.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 9/08/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CardinalKit

class CKResearchSurveysManager: NSObject {
    static let shared = CKResearchSurveysManager()
    
    func getTaskItems(onCompletion: @escaping (Any) -> Void){
        guard let surveysPath = CKStudyUser.shared.surveysCollection else {
            onCompletion(false)
            return
        }
        var AllItems=[CloudTaskItem]()
        CKActivityManager.shared.fetchData(route: surveysPath,onCompletion: {(results) in
            if let results = results as? [String:Any]{
                var counter=results.count
                for (id, data) in results {
                   
                    CKActivityManager.shared.fetchData(route: surveysPath+"\(id)/questions/", onCompletion: {
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
                                let taskItem: CloudTaskItem = CloudTaskItem(order: order, title: title, subtitle: subtitle, imageName: imageName, section: section, identifier: identifier, questions: questions)
                                AllItems.append(taskItem)
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
    }
}
