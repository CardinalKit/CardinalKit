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
    
    func collect() {
        for type in types {
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                guard let samples = samples as? [HKClinicalRecord] else {
                    print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                    return
                }
                
                print("[CKHealthRecordsManager] collect() - sending \(samples.count) sample(s)")
                for sample in samples {
                    guard let resource = sample.fhirResource else { continue }
                    
                    // https://github.com/apple/FHIRModels
                    do {
                        let data = resource.data
                        
                        if let json = try CKSendHelper.jsonDataAsDict(data) {
                            try CKSendHelper.sendToFirestore(json, collection: "health-records")
                        }
                        
                        /* let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: [])
                        print(jsonDictionary)
                        
                        let resourceData = OCKFHIRResourceData<R4, JSON>(data: data)
                        let coder = OCKR4PatientCoder()
                    
                        let patient: OCKPatient = try coder.decode(resourceData)
                        print(patient)*/
                    } catch {
                        print(error)
                    }
                    print("------")
                }
                
                
            }
            healthStore.execute(query)
        }
    }
    
}
