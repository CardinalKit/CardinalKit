//
//  TaskPresenter.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class TaskPresenter: ObservableObject{
    @Published var todayDate:String
    
    @Published var itemsSections:[String] = []
    @Published var items:[String:[TaskItem]] = [:]
    
    @Published var studyTitle:String
    @Published var teamName:String
    
    init(){
        todayDate = Date().shortStringFromDate()
        let config = CKPropertyReader(file: "CKConfiguration")
        let useCloud:Bool = config.readBool(query: "Use Cloud Surveys")
        let TaskMock = TaskItemMock()
        studyTitle = config.read(query: "Study Title")
        teamName = config.read(query: "Team Name")
        TaskMock.getItems(useCloud: useCloud){ items, sections in
            self.items = items
            self.itemsSections = sections
        }
    }
}
