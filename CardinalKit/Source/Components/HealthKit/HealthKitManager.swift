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
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(HealthKitManager.syncData), name: NSNotification.Name(rawValue: Constants.Notification.DataSyncRequest), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.DataSyncRequest),
                                                  object: nil)
    }
    
    // IMPORTANT
    // It is not possible to get the status for the 'Read Data' because Apple think it is sensitive issue
    // Thus we will keep "step counts" as a dummy variable to check whether
    // the user has given permission for the health kit
    /* func hasHealthKitPermissions() -> Bool {
        
        for quantity in healthDataItemsToWrite {
            
            if healthStore.authorizationStatus(for: quantity) != .sharingAuthorized {
                
                return false
            }
            
        }
        
        return true
    }*/
    
    public func getHealthKitAuth(forTypes types: Set<HKQuantityType>, _ completion: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() && SessionManager.shared.userId != nil else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
            completion(false, error)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: types) {
            [weak self] success, error in
            
            guard let strongSelf = self else { return }
            strongSelf.userAuthorizedHKOnDevice = success
            
            completion(success, error as NSError?)
        }
    }
    
    public func startBackgroundDelivery(forTypes types: Set<HKQuantityType>, withFrequency frequency: HKUpdateFrequency, _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        self.setUpBackgroundDeliveryForDataTypes(types: types, frequency: frequency, completion)
    }
    
    public func disableHealthKit(_ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        healthStore.disableAllBackgroundDelivery { (success, error) in
            if let error = error {
                VError("Unable to disable HK background delivery %@", error.localizedDescription)
            }
            completion?(success, error)
        }
    }
    
}

extension HealthKitManager {
    
    fileprivate func setUpBackgroundDeliveryForDataTypes(types: Set<HKQuantityType>, frequency: HKUpdateFrequency, _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {

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
                
                /* dispatchGroup.enter()
                strongSelf.cumulativeBackgroundQuery(forType: type, completionHandler: {
                    dispatchGroup.leave()
                })*/
                
                dispatchGroup.notify(queue: .main, execute: {
                    completionHandler()
                })
                
            })
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: frequency, withCompletion: { (success, error) in
                if let error = error {
                    VError("%@", error.localizedDescription)
                }
                completion?(success, error)
            })
            
        }
    }
    
    //TODO: (delete) running the old data collection solution as a baseline to compare new values
    @available(*, deprecated)
    fileprivate func cumulativeBackgroundQuery(forType type: HKQuantityType, completionHandler: @escaping ()->Void) {
        
        let supportedTypes = [HKQuantityTypeIdentifier.stepCount.rawValue, HKQuantityTypeIdentifier.flightsClimbed.rawValue, HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue]
        if (!supportedTypes.contains(type.identifier)) {
            VLog("No cumulative query will run for type %@", type.identifier)
            completionHandler()
            return
        }
        
        guard canQuery(forType: type) else {
            VLog("Cannot yet query for %@, please try again in a minute.", type.identifier)
            completionHandler()
            return
        }
        DispatchQueue.main.async { //run on main queue, which exists even if the app is 100% in the background.
        
            VLog("[DEPRECATED] cumulative querying for type %@", type.identifier)
            HealthKitCollector.shared.collectAndSendSinceStartOfDay {
                VLog("[DEPRECATED] cumulative dollection done with type %@", type.identifier)
                completionHandler()
            }
        }
        
    }
    
    fileprivate func backgroundQuery(forType type: HKQuantityType, completionHandler: @escaping ()->Void) {
        
        guard canQuery(forType: type) else {
            VLog("Cannot yet query for %{public}@, please try again in a minute.", type.identifier)
            completionHandler()
            return
        }
        
        DispatchQueue.main.async { //run on main queue, which exists even if the app is 100% in the background.
            
            VLog("Querying for type %{public}@", type.identifier)
            HealthKitDataSync.shared.collectAndUploadData(forType: type, onCompletion: {
                // VLog("Done with type %@", type.identifier)
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
        
        if currentDate.addingTimeInterval(-timeBetweenQueries) >= lastQueryDate {
            queryLog[type.identifier] = currentDate
            return true
        }
        
        VLog("canQuery is returning false for type, knowing lastQuery and currentDate = %{public}@", type.identifier, lastQueryDate.ISOStringFromDate(), currentDate.ISOStringFromDate());
        
        return false
    }
    
    @objc fileprivate func syncData(forHkTypes hkTypes: Set<HKQuantityType>) {
        for type in hkTypes {
            HealthKitDataSync.shared.collectAndUploadData(forType: type, onCompletion: nil)
        }
    }
    
}
