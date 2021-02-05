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
    case GeneralPatientSurvey,
         MedicineSurvey
    
    /*
     * STEP (2) for each item, what should its
     * title on the list be?
     */
    var title: String {
        switch self {
        case .GeneralPatientSurvey:
            return "Patient Questionaire"
        case .MedicineSurvey:
            return "Medical Questionaire"
        }
    }
    
    /*
     * STEP (3) do you need a subtitle?
     */
    var subtitle: String {
        switch self {
        case .GeneralPatientSurvey:
            return "Check in on your general health"
        case .MedicineSurvey:
            return "Check in on your current medical situation"
        }
    }
    
    /*
     * STEP (4) what image would you like to associate
     * with this item under the list view?
     * Check the Assets directory.
     */
    var image: UIImage? {
        switch self {
        default:
            return getImage(named: "SurveyIcon")
        }
    }
    
    /*
     * STEP (5) what section should each item be under?
     */
    var section: String {
        switch self {
        case .GeneralPatientSurvey, .MedicineSurvey:
            return "Current Tasks"
        }
    }

    /*
     * STEP (6) when each element is tapped, what should happen?
     * define a SwiftUI View & return as AnyView.
     */
    var action: some View {
        switch self {
        case .GeneralPatientSurvey:
            return AnyView(CKTaskViewController(tasks: GeneralPatientQuestionnaire.form))
        case .MedicineSurvey:
            return AnyView(CKTaskViewController(tasks: MedicationQuestionnaire.form))
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
