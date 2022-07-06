//
//  TaskItemPresenter.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 6/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class TaskItemPresenter: ObservableObject {
    @Published var item: TaskItem
    @Published var showDetail:Bool
    
    init(item:TaskItem){
        self.item = item
        self.showDetail = false
    }
}
