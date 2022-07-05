//
//  OnboardingViewController+Coordinator.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ResearchKit
import CardinalKit

class OnboardingViewCoordinator: NSObject, ORKTaskViewControllerDelegate {
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
        
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
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            // if we completed the onboarding task view controller, go to study.
            // performSegue(withIdentifier: "unwindToStudy", sender: nil)
            
            // TODO: where to go next?
            // trigger "Studies UI"
            UserDefaults.standard.set(true, forKey: Constants.onboardingDidComplete)
            NotificationCenter.default.post(name: .onBoardingStateChange, object: true)
            
            if let signatureResult = taskViewController.result.stepResult(forStepIdentifier: "ConsentReviewStep")?.results?.first as? ORKConsentSignatureResult {
                
                let consentDocument = ConsentDocument()
                signatureResult.apply(to: consentDocument)
                
                consentDocument.makePDF { (data, error) -> Void in
                    
                    let config = CKPropertyReader(file: "CKConfiguration")
                    let consentFileName = config.read(query: "Consent File Name")
                    
                    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
                    docURL = docURL?.appendingPathComponent("\(consentFileName).pdf") as NSURL?
                    
                    
                    do {
                        let url = docURL! as URL
                        try data?.write(to: url)
                        
                        UserDefaults.standard.set(url.path, forKey: "consentFormURL")
                        
                        if let DocumentCollection = CKStudyUser.shared.authCollection {
                            let networkingLibrary = Dependencies.container.resolve(NetworkingLibrary.self)!
                            networkingLibrary.sendFile(url: url, path: "\(DocumentCollection)/\(consentFileName).pdf")
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
            
            print("Login successful! task: \(taskViewController.task?.identifier ?? "(no ID)")")
            
            fallthrough
        default:
            // otherwise dismiss onboarding without proceeding.
            taskViewController.dismiss(animated: false, completion: nil)
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        let authLibrary = Dependencies.container.resolve(AuthLibrary.self)!
        // MARK: - Advanced Concepts
        // Sometimes we might want some custom logic
        // to run when a step appears 🎩
        
        if stepViewController.step?.identifier == PasswordlessLoginStep.identifier {
            
            /* **************************************************************
             * When the login step appears, asking for the patient's email
             **************************************************************/
            if let _ =  authLibrary.user?.email {
                // if we already have an email, go forward and continue.
                DispatchQueue.main.async {
                    stepViewController.goForward()
                }
            }
            
        } else if (stepViewController.step?.identifier == "RegistrationStep") {
            
            if let _ = authLibrary.user?.email {
                // if we already have an email, go forward and continue.
                DispatchQueue.main.async {
                    stepViewController.goForward()
                }
            }
            
        } else if (stepViewController.step?.identifier == "LoginStep") {
            
            if let _ = authLibrary.user?.email {
                // good — we have an email!
            } else {
                let alert = UIAlertController(title: nil, message: "Creating account...", preferredStyle: .alert)
                
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();
                
                alert.view.addSubview(loadingIndicator)
                taskViewController.present(alert, animated: false, completion: nil)
                
                let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
                if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                    if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        let authLibrary = Dependencies.container.resolve(AuthLibrary.self)!
                        authLibrary.RegisterUser(email: email, pass: pass, onSuccess: {
                            alert.dismiss(animated: false, completion: nil)
                            print("Created user!")
                        }, onError: { error in
                            alert.dismiss(animated: false, completion: nil)
                            
                            let alert = UIAlertController(title: "Registration Error!", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                            taskViewController.present(alert, animated: false)
                            stepViewController.goBackward()
                        })
                    }
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
        case is CKMultipleSignInStep:
            return CKMultipleSignInStepViewController(step: step)
        case is CKReviewConsentDocument:
            return CKReviewConsentDocumentViewController(step: step)
        default:
            return nil
        }
    }
}
