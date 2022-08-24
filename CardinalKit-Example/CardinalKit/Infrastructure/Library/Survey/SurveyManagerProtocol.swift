//
//  SurveyManagerProtocol.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

/***
 This protocol defines the correct methods for getting surveys from the database and saving them back.
 */
protocol SurveyManager {
    func getSurveyCloudItems(onCompletion: @escaping ([TaskItem]) -> Void)
    func getLocalSurveyItems(onCompletion: @escaping ([TaskItem]) -> Void)
    var localSurveys: [String : TaskItem] { get }
    func foundSurvey(surveyId:String,onCompletion: @escaping (TaskItem) -> Void)
}
