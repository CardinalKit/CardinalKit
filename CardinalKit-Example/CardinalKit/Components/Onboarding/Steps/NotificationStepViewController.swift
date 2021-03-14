//
//  NotificationStepViewController.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 3/13/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import HealthKit
import ResearchKit
import CardinalKit

class NotificationStep: ORKInstructionStep {
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        let config = CKConfig.shared
        
        title = NSLocalizedString(config.read(query: "Notifications Title"), comment: "")
        text = NSLocalizedString(config.read(query: "Notifications Text"), comment: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class NotificationStepViewController: ORKInstructionStepViewController {
    
    override func goForward() {
        /*
        let manager = CKHealthKitManager.shared
        manager.getHealthAuthorization() { _,_ in
            OperationQueue.main.addOperation {
                super.goForward()
            }
        }
        */
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                // Handle the error here.
                print("An error occurred: \(error)")
            }
            // Enable or disable features based on the authorization.
            print("Permission granted: \(granted)")
        }
        
        OperationQueue.main.addOperation {
            super.goForward()
        }
        
    }
}

