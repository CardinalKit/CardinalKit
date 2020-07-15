//
//  CKActivityManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation
import HealthKit

public class CKActivityManager : NSObject {
    
    public static let shared = CKActivityManager()
    
    public override init() {
        super.init()
        
        _ = HealthKitManager.shared
    }
    
    public func load() {
        guard hasGrantedAuth && !typesToCollect.isEmpty else {
            return
        }
        
        getHealthAuthorizaton(forTypes: self.typesToCollect) { [weak self] (success, error) in
            if (success) {
                self?.startHealthKitCollectionInBackground(withFrequency: .hourly) // TODO: get last freq
            }
        }
    }
    
    public func getHealthAuthorizaton(forTypes typesToCollect:Set<HKQuantityType>, _ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.typesToCollect = typesToCollect
        HealthKitManager.shared.getHealthKitAuth(forTypes: self.typesToCollect) { [weak self] (success, error) in
            self?.hasGrantedAuth = success
            completion(success, error)
        }
    }
    
    public func startHealthKitCollectionInBackground(fromStartDate startDate: Date? = nil, withFrequency frequency: HKUpdateFrequency, _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        
        //check for auth
        guard hasGrantedAuth else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot startHealthKitCollection without getting auth permissions first."])
            completion?(false, error)
            return
        }
        
        //record beginning of data collection
        if let startDate = startDate {
            UserDefaults.standard.set(startDate, forKey: Constants.UserDefaults.HKStartDate)
        }
        
        //and get health authorization
        HealthKitManager.shared.startBackgroundDelivery(forTypes: typesToCollect, withFrequency: frequency) { [weak self] (success, error) in
            self?.hasStartedCollection = success
            completion?(success, error)
        }
    }
    
    public func stopHealthKitCollection() {
        HealthKitManager.shared.disableHealthKit() { [weak self] (success, error) in
            if (success) { //disable successfully
                self?.hasStartedCollection = false //we have disabled
            }
        }
    }
    
     fileprivate let keyHasStartedCollection = "hasStartedCollection"
     fileprivate let keyHasGrantedAuth = "hasGrantedAuth"
     fileprivate let keyTypesToCollect = "typesToCollect"
     
     fileprivate var hasStartedCollection : Bool {
         get {
             return UserDefaults.standard.bool(forKey: keyHasStartedCollection)
         }
         set {
             UserDefaults.standard.set(newValue, forKey: keyHasStartedCollection)
         }
     }
     
     fileprivate var hasGrantedAuth : Bool {
         get {
             return UserDefaults.standard.bool(forKey: keyHasGrantedAuth)
         }
         set {
             UserDefaults.standard.set(newValue, forKey: keyHasGrantedAuth)
         }
     }
     
     fileprivate var _typesToCollect = Set<HKQuantityType>()
     fileprivate var typesToCollect: Set<HKQuantityType> {
         get {
             if (!_typesToCollect.isEmpty) {
                 return _typesToCollect
             }
             
             guard let typeIds = UserDefaults.standard.array(forKey: keyTypesToCollect) as? [String] else {
                 return Set<HKQuantityType>() // no types to process
             }
             
             var types = Set<HKQuantityType>()
             for type in typeIds {
                 let type = HKQuantityTypeIdentifier(rawValue: type)
                 if let parsedType = HKQuantityType.quantityType(forIdentifier: type) {
                     types.insert(parsedType)
                 }
             }
             
             if (!types.isEmpty) {
                 _typesToCollect = types
             }
             return types
         }
         set {
             var typeIds = [String]()
             for type in newValue {
                 typeIds.append(type.identifier)
             }
             UserDefaults.standard.set(typeIds, forKey: keyTypesToCollect)
             _typesToCollect = newValue
         }
     }
    
}
