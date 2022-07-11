//
//  CKCareKitManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore
import CardinalKit

class CKCareKitManager: NSObject {
    
    let coreDataStore = OCKStore(name: "CKCareKitStore")
    private(set) var synchronizedStoreManager: OCKSynchronizedStoreManager!
    
    static let shared = CKCareKitManager()
    
    override init() {
        super.init()
        initStore()
        let coordinator = OCKStoreCoordinator()
        coordinator.attach(store: coreDataStore)
        synchronizedStoreManager = OCKSynchronizedStoreManager(wrapping: coordinator)
    }
    
    func wipe() throws {
        try coreDataStore.delete()
    }
    
    fileprivate func initStore(forceUpdate: Bool = false) {
        UserDefaults.standard.set(Date(), forKey: Constants.prefCareKitCoreDataInitDate)
    }
    
    func reviewIfFirstTime(){
        guard let authCollection = CKStudyUser.shared.authCollection else {
            return
        }
        let schedulePath = "\(authCollection)schedule/data"
        CKApp.requestData(route: schedulePath){ response in
            if let response = response as? [String:Any]{
                // If not data on response
                if response.count == 0 {
                    self.addFirstTimeTasks()
                }
            }
            print("response")
        }
    }
    
    func addFirstTimeTasks(){
        // Create task items Example
        // Example daily step goal
        let stepInterval = Interval(day: 1)
        let taskItemDailyStep = ScheduleModel(id: "steps", title: "Daily Steps Goal 🏃🏽‍♂️", instructions: "Complete daily steps goal", type: .steps, surveyId: nil, startDate: Date(), endDate: nil, interval: stepInterval)
        guard let authCollection = CKStudyUser.shared.authCollection else {
            return
        }
        let schedulePath = "\(authCollection)schedule"
        CKApp.createScheduleItems(route: schedulePath, items: [taskItemDailyStep]){ success in
            print(success)
        }
        
    }
    
}
