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
import CardinalKit

class CKHealthKitManager : NSObject {
    
    static let shared = CKHealthKitManager()
    
    // TODO: save as configurable element
    fileprivate var hkTypesToReadInBackground: Set<HKSampleType> = []
    
    fileprivate let config = CKConfig.shared
    
    /// Query for HealthKit Authorization
    /// - Parameter completion: (success, error)
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        // handle authorization from the OS
        CKApp.getHealthAuthorization(forTypes: hkTypesToReadInBackground) { [weak self] (success, error) in
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
    
    
    func collectAllTypes(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        // handle authorization from the OS
        CKApp.getHealthAuthorization(forTypes: hkTypesToReadInBackground) {(success, error) in
            DispatchQueue.main.async {
                if (success) {
                    CKActivityManager.shared.collectAllDataBetweenSpecificDates(fromDate: Date().dayByAdding(-10), completion)
                }
                completion(success, error)
            }
        }
    }
    
}
