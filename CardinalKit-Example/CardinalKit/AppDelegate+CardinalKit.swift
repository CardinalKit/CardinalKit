//
//  AppDelegate+CardinalKit.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import ResearchKit
import Firebase
import CardinalKit

// Extensions add new functionality to an existing class, structure, enumeration, or protocol type.
// https://docs.swift.org/swift-book/LanguageGuide/Extensions.html
extension AppDelegate {
    
    /**
     Handle special CardinalKit logic for when the app is launched.
    */
    func CKAppLaunch() {
        
        // (1) setup the CardinalKit SDK
        var options = CKAppOptions()
        CKApp.configure(options)
        
        // (2) if we have already logged in
        if CKStudyUser.shared.isLoggedIn {
            CKStudyUser.shared.save()
            
            // (3) then start the requested HK data collection (if any).
            let manager = CKHealthKitManager.shared
            manager.getHealthAuthorization { (success, error) in
                if let error = error {
                    print(error)
                }
            }
        }
        CKStudyUser.shared.save()
    }
    
}
