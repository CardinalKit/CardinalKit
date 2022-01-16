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
import FirebaseFirestore

internal extension OCKStore {

    fileprivate func insertDocuments(documents: [DocumentSnapshot]?, collection: String, authCollection: String?,lastUpdateDate: Date?,onCompletion: @escaping (Error?)->Void){
        guard let documents = documents,
             documents.count>0 else {
           onCompletion(nil)
           return
       }
        
        let group = DispatchGroup()
        for document in documents{
            group.enter()
            CKSendHelper.getFromFirestore(authCollection:authCollection, collection: collection, identifier: document.documentID) {(document, error) in
                do{
                    guard let document = document,
                          let payload = document.data(),
                          let id = payload["id"] as? String else {
                              group.leave()
                        return
                    }
                    var itemSchedule:OCKSchedule? = nil
                    var update = true
                    if lastUpdateDate != nil,
                       let updateTimeServer = payload["updateTime"] as? Timestamp,
                       updateTimeServer.dateValue()<lastUpdateDate!{
                        update = false
                    }
                    
                    if update,
                        let schedule = payload["scheduleElements"] as? [[String:Any]]
                    {
                        var scheduleElements=[OCKScheduleElement]()
                        for element in schedule{
                            var startDate = Date()
                            var endDate:Date?=nil
                            var intervalDate = DateComponents(day:2)
                            var durationElement:OCKScheduleElement.Duration = .allDay
                            if let startStamp = element["startTime"] as? Timestamp{
                                startDate = startStamp.dateValue()
                            }
                            if let endStamp = element["endTime"] as? Timestamp{
                                endDate = endStamp.dateValue()
                            }
                            
                            if let interval = element["interval"] as? [String:Any]{
                                var day = 1
                                if let dayInterval = interval["day"] as? Int{
                                    day = dayInterval
                                }
                                var seconds = 1
                                if let secondsInterval = interval["seconds"] as? Int{
                                    seconds = secondsInterval
                                }
                                intervalDate =
                                    DateComponents(
                                        timeZone: interval["timeZone"] as? TimeZone,
                                        year: interval["year"] as? Int,
                                        month: interval["month"] as? Int,
                                        day: day,
                                        hour: interval["hour"] as? Int,
                                        minute: interval["minute"] as? Int,
                                        second: seconds,
                                        weekday: interval["weekday"] as? Int,
                                        weekdayOrdinal: interval["weekdayOrdinal"] as? Int,
                                        weekOfMonth: interval["weekOfMonth"] as? Int,
                                        weekOfYear: interval["weekOfYear"] as? Int,
                                        yearForWeekOfYear: interval["yearForWeekOfYear"] as? Int)
                            }
                            if let duration = element["duration"] as? [String:Any]{
                                if let allDay = duration["allDay"] as? Bool,
                                   allDay{
                                    durationElement = .allDay
                                }
                                if let seconds = duration["seconds"] as? Double{
                                    durationElement = .seconds(seconds)
                                }
                                if let hours = duration["hours"] as? Double{
                                    durationElement = .hours(hours)
                                }
                                if let minutes = duration["minutes"] as? Double{
                                    durationElement = .minutes(minutes)
                                }
                            }
                            var targetValue:[OCKOutcomeValue] = [OCKOutcomeValue]()
                            if let targetValues = element["targetValues"] as? [[String:Any]]{
                                for target in targetValues{
                                    if let identifier = target["groupIdentifier"] as? String{
                                        var come = OCKOutcomeValue(false, units: nil)
                                            come.groupIdentifier=identifier
                                        targetValue.append(come)
                                    }
                                }
                            }
                            scheduleElements.append(OCKScheduleElement(start: startDate, end: endDate, interval: intervalDate, text: element["text"] as? String, targetValues: targetValue, duration: durationElement))
                        }
                        if scheduleElements.count>0{
                            itemSchedule = OCKSchedule(composing: scheduleElements)
                        }
                    }
                    if let itemSchedule = itemSchedule{
                        var uuid:UUID? = nil
                        if let _uuid = payload["uuid"] as? String{
                            uuid=UUID(uuidString: _uuid)
                        }
                        var task = OCKTask(id: id, title: payload["title"] as? String, carePlanUUID: uuid, schedule: itemSchedule)
                        if let impactsAdherence = payload["impactsAdherence"] as? Bool{
                            task.impactsAdherence = impactsAdherence
                        }
                        task.instructions = payload["instructions"] as? String
                        
//                        This will make it so future surveys show up properly
//                        It also means they can be filled out
//                        TODO: add some kind of task.fillableDate
                        task.effectiveDate = Date()

                        // get if task exist?
                        self.fetchTask(withID: id) { result in
                            switch result {
                                case .failure(_): do {
                                    self.addTask(task)
                                }
                            case .success(_):do {
                                self.updateTask(task)
                                }
                            }

                            group.leave()
                        }
                    }
                    else{
                        group.leave()
                    }
                    
                }
            }
        }
        group.notify(queue: .main, execute: {
            onCompletion(nil)
        })
    }
    // Adds tasks and contacts into the store
    func populateSampleData(lastUpdateDate: Date?,completion:@escaping () -> Void) {
        
        let collection: String = "carekit-store/v2/tasks"
        // Download Tasks By Study
        
        guard  let studyCollection = CKStudyUser.shared.studyCollection else {
            return
        }
        // Get tasks on study
        CKSendHelper.getFromFirestore(authCollection: studyCollection,collection: collection, onCompletion: { (documents,error) in
            self.insertDocuments(documents: documents, collection: collection, authCollection: studyCollection,lastUpdateDate:lastUpdateDate){
                (Error) in
                CKSendHelper.getFromFirestore(collection: collection, onCompletion: { (documents,error) in
                    self.insertDocuments(documents: documents, collection: collection, authCollection: nil,lastUpdateDate:lastUpdateDate){
                        (Error) in
                        self.createContacts()
                        completion()
                    }
                })
            }
        })
    }
    
    func createContacts() {
        let config = CKPropertyReader(file: "CKConfiguration")
        let contactData = config.readAny(query: "Contacts") as! [[String:String]]
//        Have to put it into a list so we can reverse the list later
        var ockContactElements: [OCKContact] = []
        for data in contactData {
            let address = OCKPostalAddress()
            var thisContact = OCKContact(id: data["givenName"]! + data["familyName"]!, givenName: data["givenName"]!, familyName: data["familyName"]!, carePlanUUID: nil)
//            If you have an image named exactly givenNamefamilyName, in assets, it will be put on contact card
            thisContact.asset = data["givenName"]! + data["familyName"]!
            for (k, v) in data {
                k == "role" ? thisContact.role = v :
                k == "title" ? thisContact.title = v :
                k == "email" ? thisContact.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: v)] :
                k == "phone" ? thisContact.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: v)] :
                k == "test" ? thisContact.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: v)] :
                k == "street" ? address.street = v :
                k == "city" ? address.city = v :
                k == "state" ? address.state = v :
                k == "postalCode" ? address.postalCode = v :
                ()
            }
            if address != OCKPostalAddress() {
                thisContact.address = address
            }
            ockContactElements.append(thisContact)
        }
//        Have to do this for them to be in what is probably the correct order
        addContacts(ockContactElements.reversed())
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
