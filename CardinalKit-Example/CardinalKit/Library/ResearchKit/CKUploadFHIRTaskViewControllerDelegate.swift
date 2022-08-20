//
//  CKUploadFHIRTaskViewControllerDelegate.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 8/12/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit
import Firebase
import ModelsR4

class CKUploadFHIRTaskViewControllerDelegate : NSObject, ORKTaskViewControllerDelegate {

    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            let converter = ResearchKitToFhir()
            let results = converter.extractResultsToFhir(result: taskViewController.result)
            print(results)
            
            fallthrough
        default:
            taskViewController.dismiss(animated: false, completion: nil)

        }
    }

}
