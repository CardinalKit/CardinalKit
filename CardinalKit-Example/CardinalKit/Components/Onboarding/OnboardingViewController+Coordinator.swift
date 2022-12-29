//
//  OnboardingViewController+Coordinator.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import CardinalKit
import Firebase
import ResearchKit


class OnboardingViewCoordinator: NSObject, ORKTaskViewControllerDelegate {
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        shouldPresent step: ORKStep
    ) -> Bool {
        // Only allow users to continue the onboarding process if they consent
        if let consentStepResult = taskViewController.result.stepResult(forStepIdentifier: "ConsentReviewStep")?.results,
           let signatureResult = consentStepResult[0] as? ORKConsentSignatureResult {
            if !signatureResult.consented {
                taskViewController.dismiss(animated: false, completion: nil)
                return false
            }
        }
        return true
    }
    
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskViewControllerFinishReason,
        error: Error?
    ) {
        let storage = Storage.storage()
        switch reason {
        case .completed:
            UserDefaults.standard.set(true, forKey: Constants.onboardingDidComplete)

            if let signatureResult = taskViewController.result.stepResult(
                forStepIdentifier: "ConsentReviewStep"
            )?.results?.first as? ORKConsentSignatureResult {
                let consentDocument = ConsentDocument()
                signatureResult.apply(to: consentDocument)
                
                consentDocument.makePDF { data, error -> Void in
                    let config = CKPropertyReader(file: "CKConfiguration")
                    let consentFileName = config.read(query: "Consent File Name") ?? "My Consent File"
                    
                    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).first
                    docURL = docURL?.appendingPathComponent("\(consentFileName).pdf")
                    
                    do {
                        guard let url = docURL else {
                            return
                        }
                        
                        try data?.write(to: url)
                        
                        UserDefaults.standard.set(url.path, forKey: "consentFormURL")
                        
                        let storageRef = storage.reference()
                        
                        if let documentCollection = CKStudyUser.shared.authCollection {
                            let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")
                            
                            documentRef.putFile(from: url, metadata: nil) { _, error in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            print("Login successful! task: \(taskViewController.task?.identifier ?? "(no ID)")")
            
            fallthrough
        default:
            taskViewController.dismiss(animated: false, completion: nil)
        }
    }

    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        stepViewControllerWillAppear stepViewController: ORKStepViewController
    ) {
        /// If we are navigating forward from the registration step, then try to register an account
        if stepViewController.step?.identifier == "LoginStep" {
            let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
            if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult,
               let email = emailRes.textAnswer {
                if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult,
                   let pass = passwordRes.textAnswer {
                    
                    /// Register a new account with given email and password using Firebase
                    Auth.auth().createUser(withEmail: email, password: pass) { _, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                /// If an error occurs, show an alert and navigate back to the registration step
                                let alert = UIAlertController(
                                    title: "Registration Error!",
                                    message: error.localizedDescription,
                                    preferredStyle: .alert
                                )
                                let action = UIAlertAction(
                                    title: "OK",
                                    style: .cancel,
                                    handler: nil
                                )
                                alert.addAction(action)
                                taskViewController.present(alert, animated: false)
                                stepViewController.goBackward()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        viewControllerFor step: ORKStep
    ) -> ORKStepViewController? {
        // Overriding the view controller of an ORKStep
        // lets us run our own code on top of what
        // ResearchKit already provides!
        
        switch step {
        case is CKHealthDataStep:
            return CKHealthDataStepViewController(step: step)
        case is CKHealthRecordsStep:
            return CKHealthRecordsStepViewController(step: step)
        case is CKMultipleSignInStep:
            return CKMultipleSignInStepViewController(step: step)
        case is CKVerifyConsentDocumentStep:
            return CKVerifyConsentDocumentStepViewController(step: step)
        default:
            return nil
        }
    }
}
