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
        coffee.impactsAdherence = false
        coffee.instructions = "Drink coffee for good spirits!"
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let atBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!
        let surveyElement = OCKScheduleElement(start: atBreakfast, end: nil, interval: DateComponents(day: 1))
        let surveySchedule = OCKSchedule(composing: [surveyElement])
        var survey = OCKTask(id: "survey", title: "Take a Survey 📝", carePlanUUID: nil, schedule: surveySchedule)
        survey.impactsAdherence = false
        survey.instructions = "You can schedule any ResearchKit survey in your app."
        
        let heartRateElement = OCKScheduleElement(start: beforeBreakfast, end: nil,
                                                  interval: DateComponents(day: 1))
        let heartRateSchedule = OCKSchedule(composing: [heartRateElement])
        var heartRateSurvey = OCKTask(id: "heartRate", title: "Report your heartrate", carePlanUUID: nil, schedule: heartRateSchedule)
        heartRateSurvey.impactsAdherence = true
        heartRateSurvey.instructions = "Reeeeeee"
        
        
        let dailyAtBreakfast = OCKScheduleElement(start: atBreakfast, end: nil, interval: DateComponents(day: 1))
        
        let schedule = OCKSchedule(composing: [dailyAtBreakfast])
        
        var bloodPressureTask = OCKTask(id: "bloodpressure", title: "Blood Pressure", carePlanUUID: nil, schedule: schedule)
        bloodPressureTask.impactsAdherence = true
        
        bloodPressureTask.instructions = "Take your daily blood pressure"
        
        
        /*
         Doxylamine and Nausea DEMO.
         */
        let doxylamineSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil,
                               interval: DateComponents(day: 2)),

            OCKScheduleElement(start: afterLunch, end: nil,
                               interval: DateComponents(day: 4))
        ])

        var doxylamine = OCKTask(id: "doxylamine", title: "Take Doxylamine",
                                 carePlanUUID: nil, schedule: doxylamineSchedule)
        doxylamine.instructions = "Take 25mg of doxylamine when you experience nausea."

        let nauseaSchedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 2),
                               text: "Anytime throughout the day", targetValues: [], duration: .allDay)
            ])

        var nausea = OCKTask(id: "nausea", title: "Track your nausea",
                             carePlanUUID: nil, schedule: nauseaSchedule)
        nausea.impactsAdherence = false
        nausea.instructions = "Tap the button below anytime you experience nausea."
        /* ---- */

        addTasks([nausea, doxylamine, survey, heartRateSurvey, coffee, bloodPressureTask], callbackQueue: .main){ result in
            switch result {
            case .success: print("Added tasks")
            case .failure(let error): print("Error: \(error)")
            }
        }

        createContacts()
    }
    
    func createContacts() {
        var contact1 = OCKContact(id: "paul", givenName: "Paul",
                                  familyName: "Wang", carePlanUUID: nil)
        contact1.asset = "PaulWang"
        contact1.title = "Cardiac Electrophysiologist"
        contact1.role = "Dr. Wang is the head of the Cardiology Study."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "pjwang@stanford.edu")]
        //contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        //contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]

        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "318 Campus Drive"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()

        var contact2 = OCKContact(id: "me", givenName: "Meg",
                                  familyName: "Babakhanian", carePlanUUID: nil)
        contact2.asset = "MegBabakhanian"
        contact2.title = " R&D Scientist Engineer"
        contact2.role = "Dr. Babakhanian is an administrator of the Cardiology Study."
        //contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(324) 555-7415")]
        contact2.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "mbabakha@stanford.edu")]
        //contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(324) 555-7415")]
        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "318 Campus Drive"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()

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
