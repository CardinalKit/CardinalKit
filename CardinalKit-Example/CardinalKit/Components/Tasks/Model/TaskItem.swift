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
    case
//         sampleResearchKitSurvey,
//         sampleResearchKitActiveTask,
//         sampleCoreMotionAppleWatch,
//         // sampleFunCoffeeSurvey,
//         sampleLearnItem,
         onboardingSurvey,
         sf12Survey,
         gaitAndBalance,
         timedWalk,
         tremor
    
    
    
    /*
     * STEP (2) for each item, what should its
     * title on the list be?
     */
    var title: String {
        switch self {
//        case .sampleResearchKitSurvey:
//            return "Survey (ResearchKit)"
//        case .sampleResearchKitActiveTask:
//            return "Active Task (ResearchKit)"
//        case .sampleCoreMotionAppleWatch:
//            return "Sensors Demo"
////        case .sampleFunCoffeeSurvey:
////            return "Coffee Survey"
//        case .sampleLearnItem:
//            return "About CardinalKit"
        case .onboardingSurvey:
            return "Onboarding Survey"
        case .sf12Survey:
            return "SF-12 Survey"
        case .gaitAndBalance:
            return "Gait and Balance Test"
        case .timedWalk:
            return "Timed Walk Test"
        case .tremor:
            return "Tremor Test"
        }
    }
    
    /*
     * STEP (3) do you need a subtitle?
     */
    var subtitle: String {
        switch self {
//        case .sampleResearchKitSurvey:
//            return "Sample questions and forms."
//        case .sampleResearchKitActiveTask:
//            return "Sample sensor/data collection activities."
//        case .sampleCoreMotionAppleWatch:
//            return "CoreMotion & Cloud Storage"
////        case .sampleFunCoffeeSurvey:
////            return "How do you like your coffee?"
//        case .sampleLearnItem:
//            return "Visit cardinalkit.org"
        case .onboardingSurvey:
            return "Onboarding Survey"
        case .sf12Survey:
            return "SF-12 Survey"
        case .gaitAndBalance:
            return "Gait and Balance Test"
        case .timedWalk:
            return "Timed Walk Test"
        case .tremor:
            return "Tremor Test"
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
////        case .sampleFunCoffeeSurvey:
////            return getImage(named: "CoffeeIcon")
//        case .sampleCoreMotionAppleWatch:
//            return getImage(named: "WatchIcon")
//        case .sampleLearnItem:
//            return getImage(named: "CKLogoIcon")
        case .gaitAndBalance:
            return getImage(named: "ActivityIcon")
        case .timedWalk:
            return getImage(named: "ActivityIcon")
        case .tremor:
            return getImage(named: "ActivityIcon")
        default:
            return getImage(named: "SurveyIcon")
        }
    }
    
    /*
     * STEP (5) what section should each item be under?
     */
    var section: String {
        switch self {
        case
            //.sampleResearchKitSurvey, .sampleResearchKitActiveTask, .sampleCoreMotionAppleWatch,
            .onboardingSurvey, .gaitAndBalance, .timedWalk, .sf12Survey, .tremor:
            return "Current Tasks"
//        case .sampleFunCoffeeSurvey:
//            return "Your Interests"
//        case .sampleLearnItem:
//            return "Learn"
        }
    }

    /*
     * STEP (6) when each element is tapped, what should happen?
     * define a SwiftUI View & return as AnyView.
     */
    var action: some View {
        switch self {
//        case .sampleResearchKitSurvey:
//            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleSurveyTask))
//        case .sampleResearchKitActiveTask:
//            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleWalkingTask))
//        case .sampleCoreMotionAppleWatch:
//            return AnyView(SensorsDemoUIView())
////        case .sampleFunCoffeeSurvey:
////            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleCoffeeTask))
//        case .sampleLearnItem:
//            return AnyView(LearnUIView())
        case .onboardingSurvey:
            return AnyView(CKTaskViewController(tasks: TaskSamples.onboardingSurveyTask))
        case .sf12Survey:
            return AnyView(CKTaskViewController(tasks: TaskSamples.sf12SurveyTask))
        case .gaitAndBalance:
            return AnyView(CKTaskViewController(tasks: TaskSamples.gaitAndBalanceTask))
        case .timedWalk:
            return AnyView(CKTaskViewController(tasks: TaskSamples.timedWalkTask))
        case .tremor:
            return AnyView(CKTaskViewController(tasks: TaskSamples.tremorTask))
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
