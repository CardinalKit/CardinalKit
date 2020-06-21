//
//  ActivityTableItem.swift
//  Survey-Sample
//
//  Created by Santiago Gutierrez on 9/16/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit

enum ActivityTableItem: Int {
    case survey, activeTask
    
    static var allValues: [ActivityTableItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }
    
    var title: String {
        switch self {
        case .survey:
            return "Survey"
        case .activeTask:
            return "Active Task"
        }
    }
    
    var subtitle: String {
        switch self {
        case .survey:
            return "Answer 6 short questions"
        case .activeTask:
            return "Active movement task!"
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
}
