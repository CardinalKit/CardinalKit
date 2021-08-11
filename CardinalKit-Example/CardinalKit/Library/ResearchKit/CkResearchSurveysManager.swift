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
        var AllItems=[TaskItem]()
        CKActivityManager.shared.fetchData(route: surveysPath,onCompletion: {(results) in
            if let results = results as? [String:Any]{
                var counter=results.count
                for (id, data) in results {
                   
                    CKActivityManager.shared.fetchData(route: surveysPath+"\(id)/questions/", onCompletion: {
                        (surveyResult) in
                        if let surveyResult = surveyResult as? [String:Any]{
                            var title=""
                            var subtitle=""
                            var imageName = ""
                            var section = ""
                            var questions:[String] = [""]
                            if let data = data as? [String:Any] {
                                title = data["title"] as? String ?? "NoTitle"
                                subtitle = data["subtitle"] as? String ?? "NoSubTitle"
                                imageName = data["imageName"] as? String ?? "NoImage"
                                section = data["section"] as? String ?? "NoSection"
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
                            
                            let taskItem: TaskItem = TaskItem(title: title, subtitle: subtitle, imageName: imageName, section: section, questions: questions)
                            AllItems.append(taskItem)
                            
                        }
                        
                        counter-=1
                        if(counter<=0){
                         onCompletion(AllItems)
                        }
                    })
                }
            }
        })
    }
}
