//
//  HealthKitManager.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import HealthKit
import Firebase

enum HealthKitError : Error {
    case notAvailable
}

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    var healthStore: HKHealthStore = HKHealthStore()
    
    //global config
    var defaultPredicate = HKQuery.predicateForSamples(withStart: Date().startOfDay, end: Date().tomorrow, options: [])
    let defaultSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    let defaultQueryLimit = Int(HKObjectQueryNoLimit)
    
    let hkTypesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.characteristicType(forIdentifier: .bloodType)!
    ]
    
    let hkTypesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    let hkTypesToReadInBackground: Set<HKQuantityType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    func getHealthAuthorization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitError.notAvailable)
            return
        }
        
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: hkTypesToWrite, read: hkTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func enableBackgroundDelivery() {
        getHealthAuthorization { [weak self] (success, _) in
            if let strongSelf = self, success {
                strongSelf.setUpBackgroundDelivery(forTypes: strongSelf.hkTypesToReadInBackground)
            }
        }
    }
    
}

extension HealthKitManager {
    
    fileprivate func setUpBackgroundDelivery(forTypes types: Set<HKQuantityType>) {
        
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { [weak self] (query, completionHandler, error) in
                
                guard let strongSelf = self else {
                    completionHandler()
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                strongSelf.query(quantityType: type, completion: { results, error in
                    if (error == nil) {
                        strongSelf.save(results, forType: type)
                        //print("background query for \(type.identifier) with \(result.count) result(s)")
                    }
                    dispatchGroup.leave()
                })
                
                dispatchGroup.notify(queue: .main, execute: {
                    completionHandler()
                })
            })
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .hourly, withCompletion: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
        }
        
    }
    
}

extension HealthKitManager {
 
    func save(_ results: [HKQuantitySample], forType type: HKQuantityType) {
        //divide results by source
        let groupedResults = results.grouped { (sample) -> String in
            return sample.device?.getKey(appendSource: sample.sourceRevision.source) ?? "Unknown"
        }
        
        groupedResults.keys.forEach { (key) in
            
            if let results = groupedResults[key],
                let stanfordRITBucket = RITConfig.shared.getAuthCollection(),
                let userId = StudyUser.shared.currentUser?.uid,
                FirebaseApp.app() != nil { //if nil, db will crash
                
                let dateString = Date().startOfDay.ISOStringFromDate()
                let identifier = Date().startOfDay.shortStringFromDate() + "-\(type.identifier)-\(key)"
                let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespaces)
                let calculatedSum = sum(results)
                
                let json: [String:Any] = ["date": dateString, "\(type.identifier)":calculatedSum]
                let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
                
                let db = Firestore.firestore()
                db.collection(stanfordRITBucket + "\(Constants.dataBucketHealthKit)").document(trimmedIdentifier).setData(dataPayload) { err in
                    
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
                
                
            }
            
        }
        
    }
    
    fileprivate func sum(_ samples: [HKQuantitySample]) -> Double {
        
        var sum: Double = 0.0
        guard let type = samples.first?.quantityType else {
            return sum
        }
        
        let unit = getUnit(for: type)
        samples.forEach { (sample) in
            sum += sample.quantity.doubleValue(for: unit)
        }
        
        return sum
        
    }
    
    //can use preferredUnits(for:completion:) if desired
    fileprivate func getUnit(for type: HKQuantityType) -> HKUnit {
        
        let id = HKQuantityTypeIdentifier(rawValue: type.identifier)
        
        switch id {
        case .distanceWalkingRunning:
            return HKUnit.meter()
        case .heartRate:
            return HKUnit.count().unitDivided(by: HKUnit.minute()) //bpm
        case .stepCount:
            fallthrough
        default:
            return HKUnit.count()
        }
        
    }
    
}

extension HealthKitManager {
    
    func query(quantityType: HKQuantityType, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, limit: Int = Int(HKObjectQueryNoLimit), completion: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        let predicate = predicate ?? defaultPredicate
        let sortDescriptor = sortDescriptor ?? defaultSortDescriptor
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            guard let samples = samples as? [HKQuantitySample] else {
                completion([HKQuantitySample](), error)
                return
            }
            
            completion(samples, error)
        }
        
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }
    
    func query(quantityTypeIdentifier: HKQuantityTypeIdentifier, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, limit: Int = Int(HKObjectQueryNoLimit), completion: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            fatalError("***should never fail when using built-in type identifiers***")
        }
        
        query(quantityType: sampleType, predicate: predicate, sortDescriptor: sortDescriptor, limit: limit, completion: completion)
    }
    
}
