//
//  LocalTaskItem.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class TaskItemMock {
    func getItems(useCloud:Bool, onCompletion:@escaping ([String:[TaskItem]],[String]) -> Void){
        if useCloud {
            getCloudValues(onCompletion:onCompletion)
        }
        else{
            calculeLocalValues(onCompletion:onCompletion)
        }
    }
                                       
                                       
    private func calculeLocalValues(onCompletion:([String:[TaskItem]],[String])  -> Void){
        var items:[String:[TaskItem]] = [:]
        var sections:[String] = []
        
        for item in localTaskItems() {
            if items[item.section] == nil {
                items[item.section] = [TaskItem]()
                sections.append(item.section)
            }
            
            items[item.section]?.append(item)
        }
        onCompletion(items,sections)
        
    }
    
    private func getCloudValues(onCompletion:@escaping ([String:[TaskItem]],[String])  -> Void){
        let surveyManager = Dependencies.container.resolve(SurveyManager.self)
        var items = [String:[TaskItem]]()
        var sections = [String]()
        surveyManager?.getSurveyCloudItems(){ results in
            for item in results {
                if items[item.section] == nil {
                    items[item.section] = [item]
                    sections.append(item.section)
                }
                else{
                    items[item.section]?.append(item)
                }
            }
            onCompletion(items,sections)
        }
    }
    
    fileprivate func localTaskItems() -> [TaskItem] {
        
        return [
            TaskItem(order:"1",title: "Survey (ResearchKit)", subtitle: "Sample questions and forms.", image: "SurveyIcon", section: "Current Tasks", taskType: .custom, tasks: TaskSamples.sampleSurveyTask),
            TaskItem(order:"2",title: "Active Task (ResearchKit)", subtitle: "Sample sensor/data collection activities.", image: "ActivityIcon", section: "Current Tasks", taskType: .custom, tasks: TaskSamples.sampleWalkingTask),
            TaskItem(order:"3",title: "Coffee Survey", subtitle: "How do you like your coffee?", image: "DataIcon", section: "Your Interests", taskType: .custom, tasks: TaskSamples.sampleCoffeeTask),
            TaskItem(order:"4",title: "Coffee Results", subtitle: "ResearchKit Charts", image: "DataIcon", section: "Your Interests", taskType: .coffeView, tasks: nil),
            TaskItem(order:"5",title: "About CardinalKit", subtitle: "Visit cardinalkit.org", image: "CKLogoIcon", section: "Learn", taskType: .learUiView, tasks: nil)
        ]
    }
    
}
