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

        let coffeeElement = OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 1))
        let coffeeSchedule = OCKSchedule(composing: [coffeeElement])
        var coffee = OCKTask(id: "coffee", title: "Drink Coffee ☕️", carePlanUUID: nil, schedule: coffeeSchedule)
        coffee.impactsAdherence = true
        coffee.instructions = "Drink coffee for good spirits!"
        
        let surveyElement = OCKScheduleElement(start: afterLunch, end: nil, interval: DateComponents(day: 1))
        let surveySchedule = OCKSchedule(composing: [surveyElement])
        var survey = OCKTask(id: "survey", title: "Take a Survey 📝", carePlanUUID: nil, schedule: surveySchedule)
        survey.impactsAdherence = true
        survey.instructions = "You can schedule any ResearchKit survey in your app."
        
        /*
         Doxylamine and Nausea DEMO.
         */
        let doxylamineSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil,
                               interval: DateComponents(day: 2)),

            OCKScheduleElement(start: afterLunch, end: nil,
                               interval: DateComponents(day: 4))
        ])

        var doxylamine = OCKTask(id: "doxylamine", title: "Take an Experience Sampling Survey",
                                 carePlanUUID: nil, schedule: doxylamineSchedule)
        doxylamine.instructions = "Take an experience sampling survey twice daily!"

        let nauseaSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 2),
                               text: "Anytime throughout the day", targetValues: [], duration: .allDay)
            ])

        var nausea = OCKTask(id: "nausea", title: "Track your nausea",
                             carePlanUUID: nil, schedule: nauseaSchedule)
        nausea.impactsAdherence = false
        nausea.instructions = "Tap the button below anytime you experience nausea."
        /* ---- */

        addTasks([nausea, doxylamine, survey, coffee], callbackQueue: .main, completion: nil)

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
