//
//  CKCareKitManager+Sample.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//
import CardinalKit
import CareKit
import CareKitStore
import Contacts
import FirebaseFirestore
import UIKit

// swiftlint:disable no_extension_access_modifier cyclomatic_complexity function_body_length closure_body_length
internal extension OCKStore {
    fileprivate func insertDocuments(
        documents: [DocumentSnapshot]?,
        collection: String,
        authCollection: String?,
        lastUpdateDate: Date?,
        onCompletion: @escaping (Error?) -> Void
    ) {
        guard let documents = documents, !documents.isEmpty else {
            onCompletion(nil)
            return
        }
        
        let group = DispatchGroup()

        for document in documents {
            group.enter()
            var route = ""
            if let authCollection = authCollection {
                route = "\(authCollection)\(collection)/\(document.documentID)"
            } else {
                guard let nAuth = CKStudyUser.shared.authCollection else {
                    return
                }
                route = "\(nAuth)\(collection)/\(document.documentID)"
            }

            CKApp.requestData(route: route, onCompletion: { result in
                do {
                    guard let document = result as? DocumentSnapshot,
                          let payload = document.data(),
                          let id = payload["id"] as? String else {
                        return
                    }

                    var itemSchedule: OCKSchedule?
                    var update = true
                    if lastUpdateDate != nil,
                       let updateTimeServer = payload["updateTime"] as? Timestamp,
                       updateTimeServer.dateValue() < lastUpdateDate! {
                        update = false
                    }
                    if update,
                       let schedule = payload["scheduleElements"] as? [[String: Any]] {
                        var scheduleElements = [OCKScheduleElement]()
                        for element in schedule {
                            var startDate = Date()
                            var endDate: Date?
                            var intervalDate = DateComponents(day: 2)
                            var durationElement: OCKScheduleElement.Duration = .allDay
                            if let startStamp = element["startTime"] as? Timestamp {
                                startDate = startStamp.dateValue()
                            }
                            if let endStamp = element["endTime"] as? Timestamp {
                                endDate = endStamp.dateValue()
                            }
                            
                            if let interval = element["interval"] as? [String: Any] {
                                var day = 1
                                if let dayInterval = interval["day"] as? Int {
                                    day = dayInterval
                                }
                                var seconds = 1
                                if let secondsInterval = interval["seconds"] as? Int {
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
                                    yearForWeekOfYear: interval["yearForWeekOfYear"] as? Int
                                )
                            }
                            if let duration = element["duration"] as? [String:Any] {
                                if let allDay = duration["allDay"] as? Bool, allDay {
                                    durationElement = .allDay
                                }
                                if let seconds = duration["seconds"] as? Double {
                                    durationElement = .seconds(seconds)
                                }
                                if let hours = duration["hours"] as? Double {
                                    durationElement = .hours(hours)
                                }
                                if let minutes = duration["minutes"] as? Double {
                                    durationElement = .minutes(minutes)
                                }
                            }
                            var targetValue: [OCKOutcomeValue] = []
                            if let targetValues = element["targetValues"] as? [[String: Any]] {
                                for target in targetValues {
                                    if let identifier = target["groupIdentifier"] as? String {
                                        var come = OCKOutcomeValue(false, units: nil)
                                        come.groupIdentifier = identifier
                                        targetValue.append(come)
                                    }
                                }
                            }
                            scheduleElements.append(
                                OCKScheduleElement(
                                    start: startDate,
                                    end: endDate,
                                    interval: intervalDate,
                                    text: element["text"] as? String,
                                    targetValues: targetValue,
                                    duration: durationElement
                                )
                            )
                        }
                        if !scheduleElements.isEmpty {
                            itemSchedule = OCKSchedule(composing: scheduleElements)
                        }
                    }
                    if let itemSchedule = itemSchedule {
                        var uuid: UUID?
                        if let uuidString = payload["uuid"] as? String {
                            uuid = UUID(uuidString: uuidString)
                        }
                        var task = OCKTask(
                            id: id,
                            title: payload["title"] as? String,
                            carePlanUUID: uuid,
                            schedule: itemSchedule
                        )
                        if let impactsAdherence = payload["impactsAdherence"] as? Bool {
                            task.impactsAdherence = impactsAdherence
                        }
                        task.instructions = payload["instructions"] as? String

                        // This fixes an issue where if cloud surveys were all in the future,
                        // they would not show up
                        // It does open up all surveys (even future) for completion
                        // TODO: make a way for the future surveys to be visible but not fillable
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
                    } else {
                        group.leave()
                    }
                }
            })
        }
        group.notify(
            queue: .main,
            execute: {
                onCompletion(nil)
            })
    }
    // Adds tasks and contacts into the store
    func populateSampleData(lastUpdateDate: Date?, completion: @escaping () -> Void) {
        let collection: String = "carekit-store/v2/tasks"
        // Download Tasks By Study
        
        guard let studyCollection = CKStudyUser.shared.studyCollection,
              let authCollection = CKStudyUser.shared.authCollection else {
            return
        }
        // Get tasks on study
        let studyRoute = studyCollection + "\(collection)"
        let authRoute = authCollection + "\(collection)"

        CKApp.requestData(route: studyRoute, onCompletion: { result in
            if let documents = result as? [DocumentSnapshot] {
                self.insertDocuments(
                    documents: documents,
                    collection: collection,
                    authCollection: studyCollection,
                    lastUpdateDate: lastUpdateDate
                ){ error in
                    CKApp.requestData(route: authRoute, onCompletion: { result in
                        if let documents = result as? [DocumentSnapshot] {
                            self.insertDocuments(
                                documents: documents,
                                collection: collection,
                                authCollection: nil,
                                lastUpdateDate: lastUpdateDate
                            ) { error in
                                self.createContacts()
                                completion()
                            }
                        }
                    })
                }
            }
        })
    }

    func createContacts() {
        let config = CKPropertyReader(file: "CKConfiguration")
        guard let contactData = config.readAny(query: "Contacts") as? [[String: String]] else {
            return
        }

        var ockContactElements: [OCKContact] = []

        for data in contactData {
            guard let givenName = data["givenName"], let familyName = data["familyName"] else {
                return
            }

            let address = OCKPostalAddress()

            var thisContact = OCKContact(
                id: givenName + "_" + familyName,
                givenName: givenName,
                familyName: familyName,
                carePlanUUID: nil
            )

            // If you have an image named exactly givenNamefamilyName, in assets,
            // it will be displayed on the contact card
            thisContact.asset = givenName + familyName
            for (key, value) in data {
                key == "role" ? thisContact.role = value :
                key == "title" ? thisContact.title = value :
                key == "email" ? thisContact.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: value)] :
                key == "phone" ? thisContact.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: value)] :
                key == "test" ? thisContact.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: value)] :
                key == "street" ? address.street = value :
                key == "city" ? address.city = value :
                key == "state" ? address.state = value :
                key == "postalCode" ? address.postalCode = value :
                ()
            }
            if address != OCKPostalAddress() {
                thisContact.address = address
            }
            ockContactElements.append(thisContact)
        }
        // Have to do this for them to be in what is probably the correct order
        addContacts(ockContactElements.reversed())
    }
}

extension OCKHealthKitPassthroughStore {
    internal func populateSampleData() {
        let schedule = OCKSchedule.dailyAtTime(
            hour: 8,
            minutes: 0,
            start: Date(),
            end: nil,
            text: nil,
            duration: .hours(12),
            targetValues: [OCKOutcomeValue(2000.0, units: "Steps")]
        )

        let steps = OCKHealthKitTask(
            id: "steps",
            title: "Daily Steps Goal 🏃🏽‍♂️",
            carePlanUUID: nil,
            schedule: schedule,
            healthKitLinkage: OCKHealthKitLinkage(
                quantityIdentifier: .stepCount,
                quantityType: .cumulative,
                unit: .count()
            )
        )

        addTasks([steps]) { result in
            switch result {
            case .success:
                print("Added tasks into HealthKitPassthroughStore!")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
