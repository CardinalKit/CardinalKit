//
//  HealthKitManager.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 1/20/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit

class HealthKitManager: SyncDelegate {
    
    static let shared = HealthKitManager()
    
    lazy var healthStore: HKHealthStore = HKHealthStore()
    
    fileprivate var queryLog = [String:Date]()
    fileprivate let queryLogMutex = NSLock()
    fileprivate let timeBetweenQueries: TimeInterval = 60 //in seconds
    
    var userAuthorizedHKOnDevice : Bool? {
        get {
            return UserDefaults.standard.value(forKey: Constants.UserDefaults.HKDataShare) as? Bool
        }
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.HKDataShare)
            CKSession.putSecure(value: String(newValue ?? false), forKey: Constants.UserDefaults.HKDataShare)
        }
    }
    
    //these items will be queried for in the background
    fileprivate let healthDataItemsToReadPassively: Set<HKQuantityType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    //these items will be used for setup only
    fileprivate let healthKitDataItemsToReadForSetup: Set<HKQuantityType> = [
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    
    //will be used to request READ permissions from HealthKit
    fileprivate var healthDataItemsToRead: Set<HKQuantityType> {
        return healthKitDataItemsToReadForSetup.union(healthDataItemsToReadPassively)
    }
    
    //will be used to request WRITE permissions from HealthKit
    fileprivate var healthDataItemsToWrite: Set<HKQuantityType> {
        return healthDataItemsToRead //we only ask for "write" permissions because the only way to verify HK permissions is if there is a "write" permission granted.
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(HealthKitManager.syncData), name: NSNotification.Name(rawValue: Constants.Notification.DataSyncRequest), object: nil)
        //SyncManager.shared.addDelegate(self)
        getHealthAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.DataSyncRequest),
                                                  object: nil)
    }
    
    // IMPORTANT
    // It is not possible to get the status for the 'Read Data' because Apple think it is sensitive issue
    // Thus we will keep "step counts" as a dummy variable to check whether
    // the user has given permission for the health kit
    func hasHealthKitPermissions() -> Bool {
        
        for quantity in healthDataItemsToWrite {
            
            if healthStore.authorizationStatus(for: quantity) != .sharingAuthorized {
                
                return false
            }
            
        }
        
        return true
    }
    
    public func getHealthAuthorization(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        guard HKHealthStore.isHealthDataAvailable() && SessionManager.shared.userId != nil else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
            completion?(false, error)
            return
        }
        
        // Get authorization to access the actividata
        healthStore.requestAuthorization(toShare: healthDataItemsToWrite, read: healthDataItemsToRead) {
            [weak self] success, error in
            
            guard let strongSelf = self else { return }
            strongSelf.userAuthorizedHKOnDevice = success
            
            guard success else { return }
            strongSelf.setUpBackgroundDeliveryForDataTypes(types: strongSelf.healthDataItemsToReadPassively)
            
            completion?(success, error as NSError?)
        }
    }
    
    public func disableHealthKit() {
        healthStore.disableAllBackgroundDelivery { (success, error) in
            if let error = error {
                VError("Unable to disable HK background delivery %@", error.localizedDescription)
            }
        }
    }
    
}

extension HealthKitManager {
    
    fileprivate func setUpBackgroundDeliveryForDataTypes(types: Set<HKQuantityType>) {
        
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { [weak self] (query, completionHandler, error) in
                
                guard let strongSelf = self else {
                    completionHandler()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                strongSelf.backgroundQuery(forType: type, completionHandler: {
                    dispatchGroup.leave()
                })
                
                /*dispatchGroup.enter()
                strongSelf.cumulativeBackgroundQuery(forType: type, completionHandler: {
                    dispatchGroup.leave()
                })*/
                
                dispatchGroup.notify(queue: .main, execute: {
                    completionHandler()
                })
                
            })
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: { (success, error) in
                if let error = error {
                    VError("%@", error.localizedDescription)
                }
            })
            
        }
    }
    
    //TODO: (delete) running the old data collection solution as a baseline to compare new values
    @available(*, deprecated)
    fileprivate func cumulativeBackgroundQuery(forType type: HKQuantityType, completionHandler: @escaping ()->Void) {
        
        guard canQuery(forType: type) else {
            VLog("Cannot yet query for %@, please try again in a minute.", type.identifier)
            completionHandler()
            return
        }
        DispatchQueue.main.async { //run on main queue, which exists even if the app is 100% in the background.
        
            VLog("[DEPRECATED] cumulative querying for type %@", type.identifier)
            HealthKitCollector.shared.collectAndSendRetroactively {
                VLog("[DEPRECATED] cumulative dollection done with type %@", type.identifier)
                completionHandler()
            }
        }
        
    }
    
    fileprivate func backgroundQuery(forType type: HKQuantityType, completionHandler: @escaping ()->Void) {
        
        guard canQuery(forType: type) else {
            VLog("Cannot yet query for %@, please try again in a minute.", type.identifier)
            completionHandler()
            return
        }
        
        DispatchQueue.main.async { //run on main queue, which exists even if the app is 100% in the background.
            
            VLog("Querying for type %@", type.identifier)
            HealthKitDataSync.shared.collectAndUploadData(forType: type, onCompletion: {
                //you can use remaining background time to perform additional operations here, such as attempting to send files that are still stuck. TODO.
                VLog("Done with type %@", type.identifier)
                completionHandler()
            })
        }
        
    }

    fileprivate func canQuery(forType type: HKQuantityType) -> Bool {
        queryLogMutex.lock()
        defer { queryLogMutex.unlock() }
        
        let currentDate = Date()
        guard let lastQueryDate = queryLog[type.identifier] else {
            queryLog[type.identifier] = currentDate
            return true
        }
        
        if lastQueryDate.addingTimeInterval(-timeBetweenQueries) >= currentDate {
            queryLog[type.identifier] = currentDate
            return true
        }
        
        return false
    }
    
    @objc fileprivate func syncData(forHkTypes hkTypes: Set<HKQuantityType>) {
        for type in hkTypes {
            HealthKitDataSync.shared.collectAndUploadData(forType: type, onCompletion: nil)
        }
    }
    
}
