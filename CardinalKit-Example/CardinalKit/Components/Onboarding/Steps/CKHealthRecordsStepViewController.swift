
//
//  CKHealthRecordsStepViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import HealthKit
import ResearchKit
import CardinalKit

class CKHealthRecordsStep: ORKInstructionStep {
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        /* **************************************************************
         * customize the instruction text that user sees when
         * requesting health data permissions.
        **************************************************************/
        
        let config = CKConfig.shared
        
        let recordsConfig = config["Health Records"] 
        
        if let _title = recordsConfig["Permissions Title"] as? String {
            title = NSLocalizedString(_title, comment: "")
        }
        
        if let _text = recordsConfig["Permissions Text"] as? String {
            text = NSLocalizedString(_text, comment: "")
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/**
 Wrapper for the `CKHealthDataStep` into a ResearchKit `ORKInstructionStepViewController`.
 
 This class was created to override the `goForward` functionality for when the `CKHealthDataStep`
 is presented in a task view.
*/
class CKHealthRecordsStepViewController: ORKInstructionStepViewController {
    
    /**
     When this step is being dismissed, get `HealthKit`  authorization in the process.
     
     Relies on a `CKHealthDataStep` instance as `self.step`.
    */
    override func goForward() {
        let manager = CKHealthRecordsManager.shared
        manager.getAuth { succeeded, _ in
            if succeeded {
                manager.upload()
            }
            
            OperationQueue.main.addOperation {
                super.goForward()
            }
        }
    }
}
