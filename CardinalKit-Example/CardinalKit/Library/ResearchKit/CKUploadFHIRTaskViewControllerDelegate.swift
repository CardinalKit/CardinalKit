//
//  CKUploadFHIRTaskViewControllerDelegate.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 8/12/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import CardinalKit
import Firebase
import Foundation
import ModelsR4
import ResearchKit


class CKUploadFHIRTaskViewControllerDelegate: NSObject, ORKTaskViewControllerDelegate {
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason,
        error: Error?
    ) {
        switch reason {
        case .completed:
            let fhirResponses = taskViewController.result.fhirResponse

            // Adds patient identifier to QuestionnaireResponse
            if let uid = CKStudyUser.shared.currentUser?.uid {
                fhirResponses.subject = Reference(reference: FHIRPrimitive(FHIRString("Patient/\(uid)")))
            }

            do {
                // Parse FHIR QuestionnaireResponse and convert it to a JSON-friendly dictionary.
                let encoder = JSONEncoder()
                let data = try encoder.encode(fhirResponses)
                let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                // Upload the FHIR QuestionnaireResponse to Firebase
                let identifier = fhirResponses.id?.value?.string ?? UUID().uuidString

                guard let authCollection = CKStudyUser.shared.authCollection,
                      let userId = CKStudyUser.shared.currentUser?.uid else {
                    return
                }

                let route = "\(authCollection)\(Constants.dataBucketFHIRQuestionnaireResponse)/\(identifier)"

                CKApp.sendData(
                    route: route,
                    data: jsonDict,
                    params: [
                        "userId": userId,
                        "merge": true
                    ]
                )
            } catch {
                print(error.localizedDescription)
            }
            fallthrough
        default:
            taskViewController.dismiss(animated: false, completion: nil)
        }
    }
}
