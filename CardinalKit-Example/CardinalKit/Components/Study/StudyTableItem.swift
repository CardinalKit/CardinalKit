//
//  StudyTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit

enum StudyTableItem: Int, CaseIterable {
    // table items
    case survey, trailMakingA, trailMakingB, spatial, speechRecognition, amslerGrid

    var task: ORKOrderedTask {
        switch self {
        case .survey:
            return StudyTasks.survey
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
        case .survey:
            return "Patient Survey"
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
        case .survey:
            return "Survey of basic health information"
        case .trailMakingA:
            return "This activity evaluates your visual activity and task"
        case .trailMakingB:
            return "This activity evaluates your visual activity and task"
        case .spatial:
            return "This activity measures your short term spacial memory"
        case .speechRecognition:
            return "This activity records your speech"
        case .amslerGrid:
            return "This activity helps with detecting problems in your vision"
        }
    }

    var image: UIImage? {
        switch self {
        case .survey:
            return UIImage(named: "survey.png")!
        case .trailMakingA:
            //return UIImage(named: "Trail Making A")
            return UIImage(named: "trailA.png")!
        case .trailMakingB:
            //return UIImage(named: "Trail Making B")
            return UIImage(named: "trailB.png")!
        case .spatial:
            //return UIImage(named: "Spatial Memory Test")
            return UIImage(named: "spatial.png")!
        case .speechRecognition:
        //return UIImage(named: "Spatial Memory Test")
            return UIImage(named: "speech.png")!
        case .amslerGrid:
            return UIImage(named: "amsler.png")!
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
