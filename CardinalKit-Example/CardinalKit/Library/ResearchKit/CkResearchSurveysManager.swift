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
        CKActivityManager.shared.fetchData(route: surveysPath,onCompletion: {(results) in
            if let results = results as? [String:Any]{
                for (id, _) in results {
                    CKActivityManager.shared.fetchData(route: surveysPath+"\(id)/questions/", onCompletion: {
                        (surveyResult) in
                        if let surveyResult = surveyResult as? [String:Any]{
                            for (questionId, question) in surveyResult{
                                print(questionId)
                                print(question)
                            }
                        }
                    })
                }
            }
        })
    }
}
