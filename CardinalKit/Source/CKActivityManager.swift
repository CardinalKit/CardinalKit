//
//  CKActivityManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation

public class CKActivityManager : NSObject {
    
    public static func startHealthKitCollection(_ completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        HealthKitManager.shared.getHealthAuthorization(completion)
    }
    
}
