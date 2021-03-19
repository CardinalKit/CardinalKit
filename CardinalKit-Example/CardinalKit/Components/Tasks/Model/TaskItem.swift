//
//  StudyTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit
import SwiftUI

enum TaskItem: Int {

    /*
     * STEP (1) APPEND TABLE ITEMS HERE,
     * Give each item a recognizable name!
     */
    case sampleResearchKitSurvey,
//         sampleResearchKitActiveTask,
//         sampleCoreMotionAppleWatch,
         // sampleFunCoffeeSurvey,

         sampleLearnItem
    
    /*
     * STEP (2) for each item, what should its
     * title on the list be?
     */
    var title: String {
        switch self {
        case .sampleResearchKitSurvey:
            return "Experience Sampling Survey"
//        case .sampleResearchKitActiveTask:
//            return "Active Task (ResearchKit)"
//        case .sampleCoreMotionAppleWatch:
//            return "Sensors Demo"
//        case .sampleFunCoffeeSurvey:
//            return "Coffee Survey"

        case .sampleLearnItem:
            return "About Digital-PD"
        }
    }
    
    /*
     * STEP (3) do you need a subtitle?
     */
    var subtitle: String {
        switch self {
        case .sampleResearchKitSurvey:
            return "Understand your mental and emotional state."
//        case .sampleResearchKitActiveTask:
//            return "Sample sensor/data collection activities."
//        case .sampleCoreMotionAppleWatch:
//            return "CoreMotion & Cloud Storage"
//        case .sampleFunCoffeeSurvey:
//            return "How do you like your coffee?"

        case .sampleLearnItem:
            return "Learn More about the Digital-PD Project"
        }
    }
    
    /*
     * STEP (4) what image would you like to associate
     * with this item under the list view?
     * Check the Assets directory.
     */
    var image: UIImage? {
        switch self {
//        case .sampleResearchKitActiveTask:
//            return getImage(named: "ActivityIcon")
//        case .sampleFunCoffeeSurvey:
//            return getImage(named: "CoffeeIcon")
//        case .sampleCoreMotionAppleWatch:
//            return getImage(named: "WatchIcon")

        case .sampleLearnItem:
            return getImage(named: "AppIcon")
        default:
            return getImage(named: "SurveyIcon")
        }
    }
    
    /*
     * STEP (5) what section should each item be under?
     */
    var section: String {
        switch self {
        case .sampleResearchKitSurvey://, .sampleResearchKitActiveTask, .sampleCoreMotionAppleWatch:

            return "Current Tasks"
        default:
            return "Other"
//        case .sampleFunCoffeeSurvey, .sampleFunCoffeeResult:
//            return "Your Interests"
//        case .sampleLearnItem, .sampleCoreMotionAppleWatch:
//            return "Learn"
        }
    }

    /*
     * STEP (6) when each element is tapped, what should happen?
     * define a SwiftUI View & return as AnyView.
     */
    var action: some View {
        switch self {
        case .sampleResearchKitSurvey:
            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleSurveyTask))
//        case .sampleResearchKitActiveTask:
//            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleWalkingTask))
//        case .sampleCoreMotionAppleWatch:
//            return AnyView(SensorsDemoUIView())
//        case .sampleFunCoffeeSurvey:
//            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleCoffeeTask))

        case .sampleLearnItem:
            return AnyView(LearnUIView())
        }
    }
    
    /*
     * HELPERS
     */
    
    fileprivate func getImage(named: String) -> UIImage? {
        UIImage(named: named) ?? UIImage(systemName: "questionmark.square")
    }
    
    static var allValues: [TaskItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }
    
}
