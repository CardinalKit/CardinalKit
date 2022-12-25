//
//  OnboardingViewController+Coordinator.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
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

    // swiftlint:disable cyclomatic_complexity
    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        stepViewControllerWillAppear stepViewController: ORKStepViewController
    ) {
        // MARK: - Advanced Concepts
        // Sometimes we might want some custom logic
        // to run when a step appears 🎩
        
        if stepViewController.step?.identifier == PasswordlessLoginStep.identifier {
            /* **************************************************************
             * When the login step appears, asking for the patient's email
             **************************************************************/
            if CKStudyUser.shared.currentUser?.email != nil {
                // if we already have an email, go forward and continue.
                DispatchQueue.main.async {
                    stepViewController.goForward()
                }
            }
        } else if stepViewController.step?.identifier == "RegistrationStep" {
            if CKStudyUser.shared.currentUser?.email != nil {
                // if we already have an email, go forward and continue.
                DispatchQueue.main.async {
                    stepViewController.goForward()
                }
            }
        } else if stepViewController.step?.identifier == "LoginStep" {
            if CKStudyUser.shared.currentUser?.email != nil {
                // good — we have an email!
            } else {
                let alert = UIAlertController(title: nil, message: "Creating account...", preferredStyle: .alert)
                
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating()
                
                alert.view.addSubview(loadingIndicator)
                taskViewController.present(alert, animated: false, completion: nil)
                
                let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
                if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                    if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        Auth.auth().createUser(withEmail: email, password: pass) { _, error in
                            DispatchQueue.main.async {
                                if let error = error {
                                    alert.dismiss(animated: false, completion: nil)
                                    if let errCode = AuthErrorCode.Code(rawValue: error._code) {
                                        switch errCode {
                                        default:
                                            let alert = UIAlertController(
                                                title: "Registration Error!",
                                                message: error.localizedDescription,
                                                preferredStyle: .alert
                                            )
                                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                            
                                            taskViewController.present(alert, animated: false)
                                        }
                                    }
                                    stepViewController.goBackward()
                                } else {
                                    alert.dismiss(animated: false, completion: nil)
                                    print("Created user!")
                                }
                            }
                        }
                    }
                }
            }
        } else if stepViewController.step?.identifier == LoginCustomWaitStep.identifier {
            /* **************************************************************
             * When the email verification step appears, send email in background!
             **************************************************************/
            
            let stepResult = taskViewController.result.stepResult(forStepIdentifier: PasswordlessLoginStep.identifier)
            if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                // if we received a valid email
                CKStudyUser.shared.sendLoginLink(email: email) { success in
                    // send a login link
                    guard success else {
                        // and react accordingly if we ran into an error.
                        DispatchQueue.main.async {
                            let config = CKPropertyReader(file: "CKConfiguration")
                            
                            Alerts.showInfo(
                                title: config.read(query: "Failed Login Title") ?? "Unable to log in.",
                                message: config.read(query: "Failed Login Text") ?? "Please try again."
                            )
                            stepViewController.goBackward()
                        }
                        return
                    }
                    
                    CKStudyUser.shared.email = email
                }
            }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        // MARK: - Advanced Concepts
        // Overriding the view controller of an ORKStep
        // lets us run our own code on top of what
        // ResearchKit already provides!
        
        switch step {
        case is CKHealthDataStep:
            // this step lets us run custom logic to ask for
            // HealthKit permissins when this step appears on screen.
            return CKHealthDataStepViewController(step: step)
        case is CKHealthRecordsStep:
            return CKHealthRecordsStepViewController(step: step)
        case is LoginCustomWaitStep:
            // run custom code to send an email for login!
            return LoginCustomWaitStepViewController(step: step)
        case is CKMultipleSignInStep:
            return CKMultipleSignInStepViewController(step: step)
        case is CKReviewConsentDocument:
            return CKReviewConsentDocumentViewController(step: step)
        default:
            return nil
        }
    }
}
