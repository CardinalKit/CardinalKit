//
//  CKHealthRecordsManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HealthKit
import CareKit
import CareKitFHIR
import CareKitStore

class CKHealthRecordsManager: NSObject {
    
    static let shared = CKHealthRecordsManager()
    
    lazy var healthStore = HKHealthStore()
    
    fileprivate let typesById: [HKClinicalTypeIdentifier] = [
        .allergyRecord, // HKClinicalTypeIdentifierAllergyRecord
        .conditionRecord, // HKClinicalTypeIdentifierConditionRecord
        .immunizationRecord, // HKClinicalTypeIdentifierImmunizationRecord
        .labResultRecord, // HKClinicalTypeIdentifierLabResultRecord
        .medicationRecord, // HKClinicalTypeIdentifierMedicationRecord
        .procedureRecord, // HKClinicalTypeIdentifierProcedureRecord
        .vitalSignRecord // HKClinicalTypeIdentifierVitalSignRecord
    ]
    
    fileprivate var types = Set<HKClinicalType>()
    
    override init() {
        super.init()
        for id in typesById {
            print(id.rawValue)
            guard let record = HKObjectType.clinicalType(forIdentifier: id) else { continue }
            types.insert(record)
        }
    }
    
    func getAuth(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: types) { (success, error) in
            completion(success, error)
        }
    }
    
    func upload(_ onCompletion: ((Bool, Error?) -> Void)? = nil) {
        for type in types {
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                guard let samples = samples as? [HKClinicalRecord] else {
                    print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                    onCompletion?(false, error)
                    return
                }
                
                print("[CKHealthRecordsManager] upload() - sending \(samples.count) sample(s)")
                for sample in samples {
                    guard let resource = sample.fhirResource else { continue }
                    do {
                        let data = resource.data
                        let identifier = resource.resourceType.rawValue + "-" + resource.identifier
                        
                        if let dict = try CKSendHelper.jsonDataAsDict(data) {
                            try CKSendHelper.sendToFirestoreWithUUID(json: dict, collection: "health-records", withIdentifier: identifier)
                        }
                    } catch {
                        print("[upload] ERROR " + error.localizedDescription)
                    }
                }
                
                UserDefaults.standard.set(Date(), forKey: Constants.prefHealthRecordsLastUploaded)
                onCompletion?(true, nil)
            }
            healthStore.execute(query)
        }
    }
    
    func collectAndUploadAll(_ onCompletion: ((Bool, Error?) -> Void)? = nil){
        CKHealthKitManager.shared.collectAllTypes({ (success, error) in
            if let error = error {
                print(error)
            }else{
                UserDefaults.standard.set(Date(), forKey: Constants.prefHealthRecordsLastUploaded)
                onCompletion?(true, nil)
            }
        })
    }
    
}
