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
    case trailMakingA, trailMakingB, spatial, speechRecognition, amslerGrid

    var task: ORKOrderedTask {
        switch self {
        case .trailMakingA:
            return StudyTasks.trailMakingA
        case .trailMakingB:
            return StudyTasks.trailMakingB
        case .spatial:
            return StudyTasks.spatial
        case .speechRecognition:
            return StudyTasks.speechRecognition
        case .amslerGrid:
            return StudyTasks.amslerGrid
        }
    }

    var title: String {
        switch self {
        case .trailMakingA:
            return "Trail Making A"
        case .trailMakingB:
            return "Trail Making B"
        case .spatial:
            return "Spatial Memory"
        case .speechRecognition:
            return "Speech Recognition"
        case .amslerGrid:
            return "Amsler Grid"
        }
    }

    var subtitle: String {
        switch self {
        case .trailMakingA:
            return "This activity evaluates your visual activity and task"
        case .trailMakingB:
            return "This activity evaluates your visual activity and task"
        case .spatial:
            return "This activity measures your short term spacial memory"
        case .speechRecognition:
            return "This activity records your speech"
        case .amslerGrid:
            return "This activity helps with detecting pronlems in your vision"
        }
    }

    var image: UIImage? {
        switch self {
        case .trailMakingA:
            //return UIImage(named: "Trail Making A")
            return UIImage(named: "Screen Shot 2020-07-29 at 6.28.25 PM.png")!
        case .trailMakingB:
            //return UIImage(named: "Trail Making B")
            return UIImage(named: "Screen Shot 2020-07-29 at 6.28.25 PM.png")!
        case .spatial:
            //return UIImage(named: "Spatial Memory Test")
            return UIImage(named: "Screen Shot 2020-07-29 at 6.28.25 PM.png")!
        case .speechRecognition:
        //return UIImage(named: "Spatial Memory Test")
            return UIImage(named: "Screen Shot 2020-07-29 at 6.28.25 PM.png")!
        case .amslerGrid:
            return UIImage(named: "Screen Shot 2020-07-29 at 6.28.25 PM.png")!
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
