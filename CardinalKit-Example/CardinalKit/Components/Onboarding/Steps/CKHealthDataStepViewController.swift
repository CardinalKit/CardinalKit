//
//  HealthDataStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import HealthKit
import ResearchKit

class CKHealthDataStep: ORKInstructionStep {
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        /* **************************************************************
         * customize the instruction text that user sees when
         * requesting health data permissions.
        **************************************************************/
        
        let config = CKConfig.shared
        
        title = config.read(query: "Health Permissions Title") ?? "Permission to read Activity Data"
        text = config.read(query: "Health Permissions Text") ?? """
            Use this text to provide an explanation to your app participants about what activity data \
            you intend to read from the Health app and why. This sample will read step count, distance, \
            heart rate, and flights climbed data.
        """
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/**
 Wrapper for the `CKHealthDataStep` into a ResearchKit `ORKInstructionStepViewController`.
 
 This class was created to override the `goForward` functionality for when the `CKHealthDataStep`
 is presented in a task view.
*/
class CKHealthDataStepViewController: ORKInstructionStepViewController {
    /**
     When this step is being dismissed, get `HealthKit`  authorization in the process.
     
     Relies on a `CKHealthDataStep` instance as `self.step`.
    */
    override func goForward() {
        let manager = CKHealthKitManager.shared
        manager.getHealthAuthorization { _, _ in
            OperationQueue.main.addOperation {
                super.goForward()
            }
        }
    }
}
