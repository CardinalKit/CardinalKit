//
//  OnboardingViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import CardinalKit

class OnboardingViewController: UIViewController {
    
    /**
    Assign this action to a "join" button in your storyboard.
    */
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        self.presentOnboarding()
    }
    
    /**
     Presents a view controller that is optimized to guide the
     onboarding experience of a patient.
     
     Uses `present()` to trigger an `ORKTaskViewController`
     as provided by the `ResearchKit` framework.
    */
    fileprivate func presentOnboarding() {
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        /* **************************************************************
        *  STEP (1): get user consent
        **************************************************************/
        // use the `ORKVisualConsentStep` from ResearchKit
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        /* **************************************************************
        *  STEP (2): ask user to review and sign consent document
        **************************************************************/
        // use the `ORKConsentReviewStep` from ResearchKit
        let signature = consentDocument.signatures!.first!
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        
        /* **************************************************************
        *  STEP (3): get permission to collect HealthKit data
        **************************************************************/
        // see `HealthDataStep` to configure!
        let healthDataStep = CKHealthDataStep(identifier: "Health")
        
        /* **************************************************************
        *  STEP (4): ask user to enter their email address for login
        **************************************************************/
        // the `LoginStep` collects and email address, and
        // the `LoginCustomWaitStep` waits for email verification.
        let loginStep = LoginStep(identifier: LoginStep.identifier)
        let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
        
        /* **************************************************************
        *  STEP (5): ask the user to create a security passcode
        *  that will be required to use this app!
        **************************************************************/
        // use the `ORKPasscodeStep` from ResearchKit.
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") //NOTE: requires NSFaceIDUsageDescription in info.plist
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")
        
        /* **************************************************************
        *  STEP (6): inform the user that they are done with sign-up!
        **************************************************************/
        // use the `ORKCompletionStep` from ResearchKit
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = config.read(query: "Completition Step Title")
        completionStep.text = config.read(query: "Completition Step Text")
        
        /* **************************************************************
        * finally, CREATE an array with the steps to show the user
        **************************************************************/
        
        // given intro steps that the user should review and consent to
        let introSteps = [consentStep, reviewConsentStep]
        
        // and steps regarding login / security
        let emailVerificationSteps = [loginStep, loginVerificationStep, passcodeStep, healthDataStep, completionStep]
        
        // guide the user through ALL steps
        let fullSteps = introSteps + emailVerificationSteps
        
        // unless they have already gotten as far as to enter an email address
        var stepsToUse = fullSteps
        if CKStudyUser.shared.email != nil {
            stepsToUse = emailVerificationSteps
        }
        
        /* **************************************************************
        * and SHOW the user these steps!
        **************************************************************/
        // create a task with each step
        let orderedTask = ORKOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = self // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        present(taskViewController, animated: true, completion: nil)
    }
    
}

extension OnboardingViewController : ORKTaskViewControllerDelegate {
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch reason {
        case .completed:
            // if we completed the onboarding task view controller, go to study.
            performSegue(withIdentifier: "unwindToStudy", sender: nil)
        default:
            // otherwise dismiss onboarding without proceeding.
            dismiss(animated: true, completion: nil)
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        // MARK: - Advanced Concepts
        // Sometimes we might want some custom logic
        // to run when a step appears 🎩
        
        if stepViewController.step?.identifier == LoginStep.identifier {
            
            /* **************************************************************
            * When the login step appears, asking for the patient's email
            **************************************************************/
            if let _ = CKStudyUser.shared.currentUser?.email {
                // if we already have an email, go forward and continue.
                DispatchQueue.main.async {
                    stepViewController.goForward()
                }
            }
            
        } else if stepViewController.step?.identifier == LoginCustomWaitStep.identifier {
            
            /* **************************************************************
            * When the email verification step appears, send email in background!
            **************************************************************/
            
            let stepResult = taskViewController.result.stepResult(forStepIdentifier: LoginStep.identifier)
            if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                
                // if we received a valid email
                CKStudyUser.shared.sendLoginLink(email: email) { (success) in
                    // send a login link
                    guard success else {
                        // and react accordingly if we ran into an error.
                        DispatchQueue.main.async {
                            let config = CKPropertyReader(file: "CKConfiguration")
                            
                            Alerts.showInfo(title: config.read(query: "Failed Login Title"), message: config.read(query: "Failed Login Text"))
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
        
        if step is CKHealthDataStep {
            // this step lets us run custom logic to ask for
            // HealthKit permissins when this step appears on screen.
            return CKHealthDataStepViewController(step: step)
        }
        
        if step is LoginCustomWaitStep {
            // run custom code to send an email for login!
            return LoginCustomWaitStepViewController(step: step)
        }
        
        return nil
    }
    
}
