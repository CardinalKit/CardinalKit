//
//  CKCareKitManager+Sample.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore
import Contacts
import UIKit

internal extension OCKStore {

    // Adds tasks and contacts into the store
    func populateSampleData() {

        let thisMorning = Calendar.current.startOfDay(for: Date())
        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: thisMorning)!
        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
        let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!

        // Professional Development Activity 1
        let pd1Element = OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 1))
        let pd1Schedule = OCKSchedule(composing: [pd1Element])
        var pd1 = OCKTask(id: "pd1", title: "Work In a New Location", carePlanUUID: nil, schedule: pd1Schedule)
        pd1.impactsAdherence = true
        pd1.instructions = "Working in a new location can promote creativity - try working in a new location today!"
        
        // Professional Development Activity 2
        let pd2Element = OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 1))
        let pd2Schedule = OCKSchedule(composing: [pd2Element])
        var pd2 = OCKTask(id: "pd2", title: "Storyboard Your Insights from a Meeting Today", carePlanUUID: nil, schedule: pd2Schedule)
        pd2.impactsAdherence = true
        pd2.instructions = "Storyboarding your work can help promote retention - try summarizing one of your meetings in visual storyboard format today."
        
        // Experience sampling surveys are scheduled twice daily
        let emaSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil,
                               interval: DateComponents(day: 1)),

            OCKScheduleElement(start: afterLunch, end: nil,
                               interval: DateComponents(day: 1))
        ])
        var survey = OCKTask(id: "survey", title: "Take a Experience Sampling Survey", carePlanUUID: nil, schedule: emaSchedule)
        survey.impactsAdherence = true
        survey.instructions = "Please take the experience sampling survey twice daily."
        
        // Checklist to track completion of EMA surveys
        var emaChecklist = OCKTask(id: "emaChecklist", title: "Track Daily Survey Completion",
                                 carePlanUUID: nil, schedule: emaSchedule)
        emaChecklist.instructions = "Track completion of the experience sampling survey here."

        /* ---- */

        addTasks([emaChecklist, survey, pd1, pd2], callbackQueue: .main, completion: nil)

        createContacts()
    }
    
    func createContacts() {
        var contact1 = OCKContact(id: "michael", givenName: "Michael",
                                  familyName: "Cooper", carePlanUUID: nil)
        contact1.asset = "MichaelCooper"
        contact1.title = "Researcher"
        contact1.role = "Michael Cooper is the lead developer of the application infrastructure for this research project."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "coopermj@stanford.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(555) 555-5555")]
        contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(555) 555-5555")]

        var contact2 = OCKContact(id: "james", givenName: "James",
                                  familyName: "Landay", carePlanUUID: nil)
        contact2.asset = "JamesLanday"
        contact2.title = "Professor of Computer Science"
        contact2.role = "Dr. Landay is a Professor of Computer Science (Human-Computer Interaction) at Stanford University."
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(555) 555-5555")]
        contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(555) 555-5555")]

        addContacts([contact2, contact1])
    }
    
}

extension OCKHealthKitPassthroughStore {

    internal func populateSampleData() {

        let schedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: nil,
            duration: .hours(12), targetValues: [OCKOutcomeValue(2000.0, units: "Steps")])

        let steps = OCKHealthKitTask(
            id: "steps",
            title: "Daily Steps Goal 🏃🏽‍♂️",
            carePlanUUID: nil,
            schedule: schedule,
            healthKitLinkage: OCKHealthKitLinkage(
                quantityIdentifier: .stepCount,
                quantityType: .cumulative,
                unit: .count()))

        addTasks([steps]) { result in
            switch result {
            case .success: print("Added tasks into HealthKitPassthroughStore!")
            case .failure(let error): print("Error: \(error)")
            }
        }
    }
}
