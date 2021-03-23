//
//  CKHealthKitManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HealthKit
import CardinalKit

class CKHealthKitManager : NSObject {
    
    static let shared = CKHealthKitManager()
    
    // TODO: save as configurable element
    fileprivate var hkTypesToReadInBackground: Set<HKQuantityType> = []
    
    fileprivate let config = CKConfig.shared
    
    override init() {
        for requestedHKType in config.readArray(query: "HealthKit Data to Read") {
            let id = HKQuantityTypeIdentifier(rawValue: "HKQuantityTypeIdentifier" + requestedHKType)
            let hkType = HKQuantityType.quantityType(forIdentifier: id)
            hkTypesToReadInBackground.insert(hkType!)
        }
    }    
    
    /// Query for HealthKit Authorization
    /// - Parameter completion: (success, error)
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        /* **************************************************************
         * customize HealthKit data that will be collected
         * in the background. Choose from any HKQuantityType:
         * https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
        **************************************************************/
        
        // handle authorization from the OS
        CKActivityManager.shared.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) { [weak self] (success, error) in
            if (success) {
                let frequency = self?.config.read(query: "Background Read Frequency")

                if frequency == "daily" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .daily)
                } else if frequency == "weekly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .weekly)
                } else if frequency == "hourly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .hourly)
                } else {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .immediate)
                }
            }
            completion(success, error)
        }
    }
    
}
