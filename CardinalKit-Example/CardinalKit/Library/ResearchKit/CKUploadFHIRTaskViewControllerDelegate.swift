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
import CardinalKit


class CKUploadFHIRTaskViewControllerDelegate: NSObject, ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            let fhirResponses = taskViewController.result.fhirResponse

            // Adds patient identifier to QuestionnaireResponse
            if let uid = CKStudyUser.shared.currentUser?.uid {
                fhirResponses.subject = Reference(reference: FHIRPrimitive(FHIRString("Patient/\(uid)")))
            }

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                // Parse result and encode it into a JSON-friendly dictionary
                let data = try encoder.encode(fhirResponses)
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                // Store the dictionary in Firebase
                let identifier = fhirResponses.id?.value?.string ?? UUID().uuidString

                guard let authCollection = CKStudyUser.shared.authCollection,
                      let userId = CKStudyUser.shared.currentUser?.uid else {
                    return
                }

                let route = "\(authCollection)\(Constants.dataBucketFHIRQuestionnaireResponse)/\(identifier)"

                CKApp.sendData(
                    route: route,
                    data: jsonDict,
                    params: ["userId": "\(userId)", "merge": true]
                )

            } catch {
                print("Unable to upload FHIR survey")
            }

            // TODO: Upload to Firestore
        default:
            break
        }

        taskViewController.dismiss(animated: false, completion: nil)
    }
}
