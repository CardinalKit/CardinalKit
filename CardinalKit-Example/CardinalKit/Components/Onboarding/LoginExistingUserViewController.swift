//
//  LoginViewController.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 3/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

struct LoginExistingUserViewController: UIViewControllerRepresentable {
    
    func makeCoordinator() -> OnboardingViewCoordinator {
        OnboardingViewCoordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let config = CKPropertyReader(file: "CKConfiguration")
        
        var loginSteps: [ORKStep]
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")
        let loginUserPassword = ORKLoginStep(identifier: "LoginExistingStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)
        loginSteps = [signInButtons, loginUserPassword]
        
        
        // set health data permissions
        let healthDataStep = CKHealthDataStep(identifier: "HealthKit")
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")
        
        //add consent if user dont have consent in cloud
        
        let consentDocument = ConsentDocument()
        /* **************************************************************
        **************************************************************/
        // use the `ORKConsentReviewStep` from ResearchKit
        let signature = consentDocument.signatures?.first
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        
        
        let consentReview = CKReviewConsentDocument(identifier: "ConsentReview")
        
        // set passcode
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")
        
        // create a task with each step
        loginSteps += [consentReview,reviewConsentStep,healthDataStep, healthRecordsStep, passcodeStep]
        
        
        
        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyLoginTask", steps: loginSteps)
//        let orderedTask = ORKOrderedTask(identifier: "StudyLoginTask", steps: loginSteps)
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicates: [booleanAnswerType],
                                                           destinationStepIdentifiers: ["LoginExistingStep"],
                                                           defaultStepIdentifier: "ConsentReview",
                                                           validateArrays: true)
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")
        
        // ADD New navigation Rule (if has or not consentDocument)
        // Consent Rule
        let resultConsent = ORKResultSelector(resultIdentifier: "ConsentReview")
        let booleanAnswerConsent = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultConsent, expectedAnswer: true)
        let predicateRuleConsent = ORKPredicateStepNavigationRule(resultPredicates: [booleanAnswerConsent],
                                                           destinationStepIdentifiers: ["HealthKit"],
                                                           defaultStepIdentifier: "ConsentReviewStep",
                                                           validateArrays: true)
        navigableTask.setNavigationRule(predicateRuleConsent, forTriggerStepIdentifier: "ConsentReview")
        
        
        
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController
    }
    
}

