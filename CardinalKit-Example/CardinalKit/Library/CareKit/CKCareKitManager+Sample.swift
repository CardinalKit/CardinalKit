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

        addTasks([nausea, doxylamine, survey, coffee], callbackQueue: .main, completion: nil)

        createContacts()
    }
    
    func createContacts() {
        var contact1 = OCKContact(id: "marc", givenName: "Marc",
                                  familyName: "Melcher", carePlanUUID: nil)
        contact1.asset = "MarcMelcher"
        contact1.title = "Transplant Surgeon"
        contact1.role = "Dr. Melcher is part of the Kidney Transplant Surgeon Team at Stanford Hopsital."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "melcherm@stanford.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 498-5688")]
        //contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        contact1.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        contact1.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/marc-melcher")]

        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "300 Pasteur Drive Rm A160, Boswell Clinic"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()

        var contact2 = OCKContact(id: "stephan", givenName: "Stephan",
                                  familyName: "Busque", carePlanUUID: nil)
        contact2.asset = "StephanBusque"
        contact2.title = "Transplant Surgeon"
        contact2.role = "Dr. Busque is part of the Kidney Transplant Surgeon Team at Stanford Hopsital."
        contact2.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "stephan.busque@stanford.edu")]
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 723-6961")]
        //contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        contact2.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 725-8418")]
        contact2.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/stephan-busque")]

        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "300 Pasteur Drive Rm A160, MC 5309"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
        
        var contact3 = OCKContact(id: "amy", givenName: "Amy",
                                  familyName: "Gallo", carePlanUUID: nil)
        contact3.asset = "AmyGallo"
        contact3.title = "Transplant Surgeon"
        contact3.role = "Dr. Gallo is part of the Kidney Transplant Surgeon Team at Stanford Hopsital."
        contact3.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "agallo@stanford.edu")]
        contact3.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 723-5454")]
        //contact3.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        contact3.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        contact3.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/amy-gallo")]

        contact3.address = {
            let address = OCKPostalAddress()
            address.street = "750 Welch Rd Ste 319, MC 5731"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
        
        var contact4 = OCKContact(id: "thomas", givenName: "Thomas",
                                  familyName: "Pham", carePlanUUID: nil)
        contact4.asset = "ThomasPham"
        contact4.title = "Transplant Surgeon"
        contact4.role = "Dr. Pham is part of the Kidney Transplant Surgeon Team at Stanford Hopsital."
        contact4.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "tpham03@stanford.edu")]
        contact4.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 498-5689")]
        //contact4.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        contact4.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        contact4.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/khoa-thomas-pham")]

        contact4.address = {
            let address = OCKPostalAddress()
            address.street = "750 Welch Rd Ste 319, MC 5731"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
        
        var contact5 = OCKContact(id: "uerica", givenName: "Uerica",
                                  familyName: "Wang", carePlanUUID: nil)
        contact5.asset = "UericaWang"
        contact5.title = "Transplant Pharmacist"
        contact5.role = "Dr. Wang is a kidney, liver, and intestinal transplant pharmacist at Stanford Health Care."
        contact5.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "uwang@stanfordhealthcare.org")]
        //contact5.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 498-5689")]
        //contact5.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        //contact5.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        //contact5.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/khoa-thomas-pham")]

        /*
        contact5.address = {
            let address = OCKPostalAddress()
            address.street = "750 Welch Rd Ste 319, MC 5731"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
         */
        
        var contact6 = OCKContact(id: "jenny", givenName: "Jenny",
                                  familyName: "Pan", carePlanUUID: nil)
        contact6.asset = "JennyPan"
        contact6.title = "Transplant Surgery Resident"
        contact6.role = "Dr. Pan is a transplant surgery resident at Stanford Healthcare."
        contact6.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "jennypan@stanford.edu")]
        //contact6.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 498-5689")]
        //contact6.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        //contact6.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        contact6.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/jenny-pan")]

        /*
        contact6.address = {
            let address = OCKPostalAddress()
            address.street = "750 Welch Rd Ste 319, MC 5731"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
         */
        
        var contact7 = OCKContact(id: "office", givenName: "Kidney Transplant",
                                  familyName: "Office", carePlanUUID: nil)
        contact7.asset = "KidneyTransplantOffice"
        //contact7.title = "Transplant Surgery Resident"
        contact7.role = "The office is open Monday to Friday from 8:30AM - 4:30PM."
        //contact7.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "jennypan@stanford.edu")]
        contact7.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 725-9891")]
        //contact7.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        //contact7.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        //contact7.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/jenny-pan")]

        contact7.address = {
            let address = OCKPostalAddress()
            address.street = "300 Pasteur Drive, Suite A160"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
        
        var contact8 = OCKContact(id: "coordinator", givenName: "Transplant",
                                  familyName: "Coordinator", carePlanUUID: nil)
        contact8.asset = "TransplantCoordinator"
        contact8.title = "On Call, After Hours"
        contact8.role = "The transplant coordinator is on call after hours."
        //contact8.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "jennypan@stanford.edu")]
        contact8.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(650) 723-6661")]
        //contact8.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(111) 111-1111")]
        //contact8.otherContactInfo = [OCKLabeledValue(label: CNLabelPhoneNumberWorkFax, value: "(650) 498-5690")]
        //contact8.otherContactInfo = [OCKLabeledValue(label: CNLabelURLAddressHomePage, value: "https://profiles.stanford.edu/jenny-pan")]

        /*
        contact8.address = {
            let address = OCKPostalAddress()
            address.street = "300 Pasteur Drive, Suite A160"
            address.city = "Stanford"
            address.state = "CA"
            address.postalCode = "94305"
            return address
        }()
         */

        addContacts([contact8, contact7, contact6, contact5, contact4, contact3, contact2, contact1])
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
