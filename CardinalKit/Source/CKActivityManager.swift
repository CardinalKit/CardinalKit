//
//  CKActivityManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation

public class CKActivityManager : NSObject {
    
    public static func startHealthKitCollection(fromStartDate startDate: Date? = nil, _ completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        
        //record beginning of data collection
        if let startDate = startDate {
            UserDefaults.standard.set(startDate, forKey: Constants.UserDefaults.HKStartDate)
        }
        
        //and get health authorization
        HealthKitManager.shared.getHealthAuthorization(completion)
    }
    
    public static func stopHealthKitCollection() {
        HealthKitManager.shared.disableHealthKit()
    }
    
}
