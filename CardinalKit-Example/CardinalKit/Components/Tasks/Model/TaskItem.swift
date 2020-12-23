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
    case sampleResearchKitSurvey, sampleResearchKitActiveTask, sampleFunCoffeeSurvey, sampleLearnItem
    
    /*
     * STEP (2) for each item, what should its
     * title on the list be?
     */
    var title: String {
        switch self {
        case .sampleResearchKitSurvey:
            return "Survey (ResearchKit)"
        case .sampleResearchKitActiveTask:
            return "Active Task (ResearchKit)"
        case .sampleFunCoffeeSurvey:
            return "Coffee Survey"
        case .sampleLearnItem:
            return "About CardinalKit"
        }
    }
    
    /*
     * STEP (3) do you need a subtitle?
     */
    var subtitle: String {
        switch self {
        case .sampleResearchKitSurvey:
            return "Sample questions and forms."
        case .sampleResearchKitActiveTask:
            return "Sample sensor/data collection activities."
        case .sampleFunCoffeeSurvey:
            return "How do you like your coffee?"
        case .sampleLearnItem:
            return "Visit cardinalkit.org"
        }
    }
    
    /*
     * STEP (4) what image would you like to associate
     * with this item under the list view?
     * Check the Assets directory.
     */
    var image: UIImage? {
        switch self {
        case .sampleResearchKitActiveTask:
            return getImage(named: "ActivityIcon")
        case .sampleFunCoffeeSurvey:
            return getImage(named: "CoffeeIcon")
        case .sampleLearnItem:
            return getImage(named: "CKLogoIcon")
        default:
            return getImage(named: "SurveyIcon")
        }
    }
    
    /*
     * STEP (5) what section should each item be under?
     */
    var section: String {
        switch self {
        case .sampleResearchKitSurvey, .sampleResearchKitActiveTask:
            return "Current Tasks"
        case .sampleFunCoffeeSurvey:
            return "Your Interests"
        case .sampleLearnItem:
            return "Learn"
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
        case .sampleResearchKitActiveTask:
            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleWalkingTask))
        case .sampleFunCoffeeSurvey:
            return AnyView(CKTaskViewController(tasks: TaskSamples.sampleCoffeeTask))
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
