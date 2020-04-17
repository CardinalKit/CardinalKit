//
//  OnboardingViewController.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import CardinalKit

class OnboardingViewController: UIViewController {
    
    // MARK: IB actions
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        let healthDataStep = HealthDataStep(identifier: "Health")
        
        let signature = consentDocument.signatures!.first!
        
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = "Review the consent form."
        reviewConsentStep.reasonForConsent = "Consent to join the Developer Health Research Study."
        
        let loginStep = LoginStep(identifier: LoginStep.identifier)
        let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
        
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") //NOTE: requires NSFaceIDUsageDescription in info.plist
        passcodeStep.text = "Now you will create a passcode to identify yourself to the app and protect access to information you've entered."
        
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "Welcome aboard."
        completionStep.text = "Thank you for joining this study."
        
        let fullSteps = [consentStep, reviewConsentStep, healthDataStep, loginStep, loginVerificationStep, passcodeStep, completionStep]
        let emailVerificationSteps = [loginStep, loginVerificationStep, passcodeStep, completionStep]
        
        var stepsToUse = fullSteps
        if StudyUser.globalEmail() != nil {
            stepsToUse = emailVerificationSteps
        }
        
        let orderedTask = ORKOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = self
        
        present(taskViewController, animated: true, completion: nil)
    }
    
}

extension OnboardingViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        
        if stepViewController.step?.identifier == LoginStep.identifier {
            
            if let _ = StudyUser.shared.currentUser?.email {
                DispatchQueue.main.async {
                    stepViewController.goForward()  //already inputted an email, continue
                }
            }
            
        } else if stepViewController.step?.identifier == LoginCustomWaitStep.identifier {
            
            let stepResult = taskViewController.result.stepResult(forStepIdentifier: LoginStep.identifier)
            if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                
                StudyUser.sendLoginLink(email: email) { (success) in
                    guard success else {
                        DispatchQueue.main.async {
                            Alerts.showInfo(title: "Unable to Login", message: "Please try again in five minutes.")
                            stepViewController.goBackward()
                        }
                        return
                    }
                    
                    StudyUser.save(email: email)
                }
                
            }
            
        }
        
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch reason {
        case .completed:
            performSegue(withIdentifier: "unwindToStudy", sender: nil)
        case .discarded, .failed, .saved:
            fallthrough
        default:
            dismiss(animated: true, completion: nil)
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if step is HealthDataStep {
            return HealthDataStepViewController(step: step)
        }
        
        if step is LoginCustomWaitStep {
            return LoginCustomWaitStepViewController(step: step)
        }
        
        return nil
    }
    
}
