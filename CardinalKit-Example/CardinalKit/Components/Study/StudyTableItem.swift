//
//  StudyTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

enum StudyTableItem: Int {
    
    static var allValues: [StudyTableItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }

    // table items
    case survey, activeTask

    var task: ORKOrderedTask {
        switch self {
        case .survey:
            return StudyTasks.sf12Task
        case .activeTask:
            return StudyTasks.walkingTask
        }
    }

    var title: String {
        switch self {
        case .survey:
            return "Survey Sample"
        case .activeTask:
            return "Active Task Sample"
        }
    }

    var subtitle: String {
        switch self {
        case .survey:
            return "Answer some short questions."
        case .activeTask:
            return "Perform an action."
        }
    }

    var image: UIImage? {
        switch self {
        case .survey:
            return UIImage(named: "SurveyIcon")
        default:
            return UIImage(named: "ActivityIcon")
        }
    }
    
//    case coffee
//
//    var task: ORKOrderedTask {
//        switch self {
//        case .coffee:
//            return StudyTasks.coffeeTask
//        }
//    }
//
//    var title: String {
//        switch self {
//        case .coffee:
//            return "Coffee Task"
//        }
//    }
//
//    var subtitle: String {
//        switch self {
//        case .coffee:
//            return "Record your coffee intake for the day."
//        }
//    }
//
//    var image: UIImage? {
//        switch self {
//        case .coffee:
//            return UIImage(named: "CoffeeIcon")
//        }
//    }
}
