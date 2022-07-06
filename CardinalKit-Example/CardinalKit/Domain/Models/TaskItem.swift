//
//  TaskItem.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 5/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftUI
import ResearchKit


enum TaskType{
    case custom
    case coffeView
    case learUiView
}

struct TaskItem: Hashable {
    
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.title == rhs.title && lhs.section == rhs.section
    }
    
    var order: String
    var title:String
    var subtitle:String
    var image:String
    var section:String
    var tasks:ORKOrderedTask?
    var taskType:TaskType
    
    init(order:String, title:String, subtitle:String, image:String, section:String, taskType: TaskType, tasks:ORKOrderedTask?) {
        self.order = order
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.section = section
        self.taskType = taskType
        self.tasks = tasks
    }
    
    func View() -> some View {
        switch taskType {
        case .custom:
            if let tasks = tasks{
                return AnyView(CKTaskViewController(tasks:tasks))
            }
            else{
                return AnyView(CKTaskViewController(tasks: TaskSamples.sampleCoffeeTask))
            }
        case .coffeView:
            return AnyView(CoffeeUIView())
        case .learUiView:
            return AnyView(LearnUIView())
        }
    }
    
    func getImage() -> UIImage {
        UIImage(named: image) ?? UIImage(systemName: "questionmark.square")!
    }
}
