//
//  HealthDataStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import HealthKit
import ResearchKit
import CardinalKit

class CKHealthDataStep: ORKInstructionStep {
    
    // TODO: save as configurable element
    let hkTypesToReadInBackground: Set<HKQuantityType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    override init(identifier: String) {
        super.init(identifier: identifier)
        
        /* **************************************************************
         * customize the instruction text that user sees when
         * requesting health data permissions.
        **************************************************************/
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        title = NSLocalizedString(config.read(query: "Health Permissions Title"), comment: "")
        text = NSLocalizedString(config.read(query: "Health Permissions Text"), comment: "")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Convenience
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        /* **************************************************************
         * customize HealthKit data that will be collected
         * in the background. Choose from any HKQuantityType:
         * https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
        **************************************************************/
        
        // handle authorization from the OS
        CKActivityManager.shared.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) { (success, error) in
            if (success) {
                let config = CKPropertyReader(file: "CKConfiguration")
                let frequency = config.read(query: "Background Read Frequency")

                if frequency == "immediate" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .immediate)
                    
                } else if frequency == "daily" {
                    
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .daily)
                    
                } else if frequency == "weekly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .weekly)
                } else if frequency == "hourly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .hourly)
                }
            }
            completion(success, error)
        }
    }
}

/**
 Wrapper for the `CKHealthDataStep` into a ResearchKit `ORKInstructionStepViewController`.
 
 This class was created to override the `goForward` functionality for when the `CKHealthDataStep`
 is presented in a task view.
*/
class CKHealthDataStepViewController: ORKInstructionStepViewController {
    
    var healthDataStep: CKHealthDataStep? {
        return step as? CKHealthDataStep
    }
    
    /**
     When this step is being dismissed, get `HealthKit`  authorization in the process.
     
     Relies on a `CKHealthDataStep` instance as `self.step`.
    */
    override func goForward() {
        healthDataStep?.getHealthAuthorization() { succeeded, _ in
            guard succeeded else { return }
            
            OperationQueue.main.addOperation {
                super.goForward()
            }
        }
    }
}
