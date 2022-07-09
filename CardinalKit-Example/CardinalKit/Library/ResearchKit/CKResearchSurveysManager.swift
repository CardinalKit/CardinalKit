//
//  CkResearchSurveysManager.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 9/08/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CardinalKit
import Firebase

class CKResearchSurveysManager: NSObject {
    static let shared = CKResearchSurveysManager()
    
    func getTaskItems(onCompletion: @escaping (Any) -> Void){

        guard let surveysPath = CKStudyUser.shared.surveysCollection else {
            onCompletion(false)
            return
        }

        // Get all surveys
        CKApp.requestData(route: surveysPath, onCompletion: { (results) in

            var allItems: [CloudTaskItem] = []

            if let results = results as? [DocumentSnapshot]{

                var documents: [String: Any] = [:]
                for document in results {
                    documents[document.documentID] = document.data()
                }

                var counter = documents.count

                for (id, data) in documents {

                    guard let data = data as? [String: Any],
                          let _identifier = data["identifier"] as? String else {
                        onCompletion(false)
                        return
                    }

                    let title = data["title"] as? String ?? "NoTitle"
                    let subtitle = data["subtitle"] as? String ?? "NoSubTitle"
                    let imageName = data["image"] as? String ?? "NoImage"
                    let section = data["section"] as? String ?? "NoSection"
                    let order = data["order"] as? String ?? "1"
                    let deleted = data["deleted"] as? Bool ?? false
                    let identifier = _identifier
                    var questions: [String] = []

                    // Get all the questions in each survey
                    CKApp.requestData(route: "\(surveysPath)\(id)/questions/") { (questionsSnapshot) in

                        if let questionsSnapshot = questionsSnapshot as? [DocumentSnapshot] {

                            var surveyQuestions: [String: Any]  = [:]
                            for question in questionsSnapshot {
                                surveyQuestions[question.documentID] = question.data()
                            }

                            for (_, question) in surveyQuestions {
                                if let question = question as? [String: Any]{
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: question, options: .prettyPrinted)
                                        let convertedString = String(data: jsonData, encoding: String.Encoding.utf8)
                                        if let stringData:String = convertedString{
                                            questions.append(stringData)
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }
                            }

                            if !questions.isEmpty && !deleted{
                                let taskItem: CloudTaskItem = CloudTaskItem(order: order, title: title, subtitle: subtitle, imageName: imageName, section: section, identifier: identifier, questions: questions)
                                allItems.append(taskItem)
                            }
                        }
                        
                        counter-=1
                        if(counter<=0){
                            allItems = allItems.sorted(by: {a,b in return a.order<b.order})
                            onCompletion(allItems)
                        }
                    }
                }
            }
        })
    }
}
