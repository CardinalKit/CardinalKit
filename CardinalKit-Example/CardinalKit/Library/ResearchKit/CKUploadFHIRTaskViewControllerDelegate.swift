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


class CKUploadFHIRTaskViewControllerDelegate: NSObject, ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            let fhirResponses = taskViewController.result.fhirResponses

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            let data = try! encoder.encode(fhirResponses)
            let json = String(decoding: data, as: UTF8.self)

            print(json)
        default:
            break
        }

        taskViewController.dismiss(animated: false, completion: nil)
    }
}
