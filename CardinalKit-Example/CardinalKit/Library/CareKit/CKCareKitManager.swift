//
//  CKCareKitManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import CareKit
import CareKitStore

class CKCareKitManager: NSObject {
    private(set) var synchronizedStoreManager: OCKSynchronizedStoreManager!

    static let shared = CKCareKitManager()

    let coreDataStore = OCKStore(
        name: "CKCareKitStore",
        type: .onDisk,
        remote: CKCareKitRemoteSyncWithFirestore()
    )

    let healthKitStore = OCKHealthKitPassthroughStore(
        name: "CKCareKitHealthKitStore",
        type: .onDisk
    )

    override init() {
        super.init()
        initStore()
        let coordinator = OCKStoreCoordinator()
        coordinator.attach(eventStore: healthKitStore)
        coordinator.attach(store: coreDataStore)
        synchronizedStoreManager = OCKSynchronizedStoreManager(wrapping: coordinator)
    }

    func wipe() throws {
        try coreDataStore.delete()
    }
   
    fileprivate func initStore(forceUpdate: Bool = false) {
        healthKitStore.populateSampleData()
        UserDefaults.standard.set(Date(), forKey: Constants.prefCareKitCoreDataInitDate)
    }
}
