//
//  SupplementalUserInformation.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 3/14/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Firebase
import CareKit
import CareKitStore
import CareKitUI

class SupplementalUserInformation : ObservableObject {
    static let shared = SupplementalUserInformation()
    
    @Published var dictionary: [String : Any]? = UserDefaults.standard.object(forKey: "supplementalUserInfo") as? [String : Any]
    
    func setSupplementalDictionary(newDict: [String : Any]?) {
        dictionary = newDict
        UserDefaults.standard.set(newDict, forKey: "supplementalUserInfo")
    }
    
    func retrieveSupplementalDictionary() -> [String : Any]? {
        return dictionary
    }
}

func refreshSupplementalUserInformation() {
    let startOfDay = Calendar.current.startOfDay(for: Date())
    let atBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!
    
    let dailyAtBreakfast = OCKScheduleElement(start: atBreakfast, end: nil, interval: DateComponents(day: 1))
    
    let schedule = OCKSchedule(composing: [dailyAtBreakfast])
    
    let bpTask = OCKTask(id: "bloodpressure", title: "Test Blood Pressure", carePlanUUID: nil, schedule: schedule)
    // task.instructions = "Test Blood Pressure"
    
    /*
     Drug + Diary Sample.
     Adapted from the Doxylamine and Nausea demo.
     */
    let thisMorning = Calendar.current.startOfDay(for: Date())
    let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: thisMorning)!
    let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
    let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!
    
    //            // the schedule time determines the task checklist value?
    //            let drugSchedule = OCKSchedule(composing: [
    //                OCKScheduleElement(start: beforeBreakfast, end: nil,
    //                                   interval: DateComponents(day: 1)),
    //                OCKScheduleElement(start: afterLunch, end: nil,
    //                                   interval: DateComponents(day: 1))
    //            ])
    //
    //            var drugTask = OCKTask(id: "drug", title: "Take Your Drug 💊",
    //                                     carePlanUUID: nil, schedule: drugSchedule)
    //            drugTask.instructions = "Tap the button below when you take your drug."
    
    let diarySchedule = OCKSchedule(composing: [
        OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 1),
                           text: "Anytime throughout the day", targetValues: [], duration: .allDay)
    ])
    
    var diaryTask = OCKTask(id: "diary", title: "Daily Diary",
                            carePlanUUID: nil, schedule: diarySchedule)
    diaryTask.impactsAdherence = false
    diaryTask.instructions = "Tap the button below anytime you ate salty food. 🍟"
    /* ---- */
    
    let store = OCKStore(name: "CKCareKitStore")
    store.addTasks([bpTask, diaryTask], callbackQueue: DispatchQueue.main, completion: {result in
        switch result {
        case .failure(let error) :
            print(error.localizedDescription)
        case .success( _) :
            print("Success!")
        }
        
    })
    
    // update current user information from Firestore
    if let email = Auth.auth().currentUser?.email {
        let db = Firestore.firestore()
        let path = "/registered-patients/"
        db.collection(path).document(email).getDocument { (document, error) in
            if let document = document, document.exists {
                SupplementalUserInformation.shared.setSupplementalDictionary(newDict: document.data())
                
                // configure the new drug tasks based on the information that we recieve here
                
                print("Attempting to extract medication names")
                if let medicationDictionary = SupplementalUserInformation.shared.retrieveSupplementalDictionary()?["medications"] as? Dictionary<String, Int> {
                    
                    for medicationName in medicationDictionary.keys {
                        print("ADDING \(medicationName) TO THE STORE")
                        let thisMorning = Calendar.current.startOfDay(for: Date())
                        let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: thisMorning)!
                        let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
                        let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!
                        
                        // the schedule time determines the task checklist value?
                        
                        let interval = medicationDictionary[medicationName]
                        let drugSchedule = OCKSchedule(composing: [
                            OCKScheduleElement(start: beforeBreakfast, end: nil,
                                               interval: DateComponents(day: interval))
                        ])
                        
                        var drugTask = OCKTask(id: "drug\(medicationName)", title: "Take \(medicationName) 💊",
                                               carePlanUUID: nil, schedule: drugSchedule)
                        drugTask.impactsAdherence = true
                        drugTask.instructions = "Tap the button below when you take your drug."
                        let store = OCKStore(name: "CKCareKitStore")
                        store.addTasks([drugTask], callbackQueue: DispatchQueue.main, completion: {result in
                            switch result {
                            case .failure(let error) :
                                print(error.localizedDescription)
                            case .success( _) :
                                print("Successfully added drug\(medicationName)!")
                            }
                        })
                    }
                    
                    
                }
            } else {
                print("Ooooof")
            }
        }
    }
}
