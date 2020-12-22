//
//  CKCareKitManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import CareKitStore

class CKCareKitManager: NSObject {
    
    let coreDataStore = OCKStore(name: "CKCareKitStore", type: .inMemory)
    let healthKitStore = OCKHealthKitPassthroughStore(name: "CKCareKitHealthKitStore", type: .inMemory)
    private(set) var synchronizedStoreManager: OCKSynchronizedStoreManager!
    
    static let shared = CKCareKitManager()
    
    override init() {
        coreDataStore.populateSampleData()
        // healthKitStore.populateSampleData()

        let coordinator = OCKStoreCoordinator()
        coordinator.attach(eventStore: healthKitStore)
        coordinator.attach(store: coreDataStore)

        synchronizedStoreManager = OCKSynchronizedStoreManager(wrapping: coordinator)
    }
    
    
}
