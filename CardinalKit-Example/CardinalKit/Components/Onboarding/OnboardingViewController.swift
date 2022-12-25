//
//  OnboardingViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Firebase
import ResearchKit
import SwiftUI
import UIKit

struct OnboardingViewController: UIViewControllerRepresentable {
    func makeCoordinator() -> OnboardingViewCoordinator {
        OnboardingViewCoordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}

    // swiftlint:disable function_body_length
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let config = CKPropertyReader(file: "CKConfiguration")

        /* **************************************************************
        *  STEP (1+2): Ask user to review, then sign consent form
        **************************************************************/
        let consentDocument = ConsentDocument()
        let signature = consentDocument.signatures?.first
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")

        /* **************************************************************
        *  STEP (3): get permission to collect HealthKit data
        **************************************************************/
        // see `HealthDataStep` to configure!
        let healthDataStep = CKHealthDataStep(identifier: "Healthkit")
        
        /* **************************************************************
        *  STEP (3.5): get permission to collect HealthKit health records data
        **************************************************************/
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")
        
        /* **************************************************************
        *  STEP (4): ask user to enter their email address for login
        **************************************************************/
        // the `LoginStep` collects and email address, and
        // the `LoginCustomWaitStep` waits for email verification.

        var loginSteps: [ORKStep]
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")
        
        let regexp = try? NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")

        let registrationText = """
        Sign up for this study using your email address.

        Your password should contain a minimum of 8 characters \
        with at least 1 uppercase, 1 lowercase, 1 number, and 1 special character.

        """

        let passcodeInvalidMessage = """
        Your password does not meet the following criteria: minimum 8 \
        characters with at least 1 uppercase alphabet, 1 lowercase \
        alphabet, 1 number and 1 special character.
        """
        
        let registerStep = ORKRegistrationStep(
            identifier: "RegistrationStep",
            title: "Registration",
            text: registrationText,
            passcodeValidationRegularExpression: regexp,
            passcodeInvalidMessage: passcodeInvalidMessage,
            options: []
        )
        
        let loginStep = ORKLoginStep(
            identifier: "LoginStep",
            title: "Login",
            text: "Log into this study.",
            loginViewControllerClass: LoginViewController.self
        )
        
        loginSteps = [signInButtons, registerStep, loginStep]

        
        /* **************************************************************
        *  STEP (5): ask the user to create a security passcode
        *  that will be required to use this app!
        **************************************************************/
        // use the `ORKPasscodeStep` from ResearchKit.
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") // NOTE: requires NSFaceIDUsageDescription in info.plist
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
        completionStep.title = config.read(query: "Completion Step Title")
        completionStep.text = config.read(query: "Completion Step Text")
        
        /* **************************************************************
        * finally, CREATE an array with the steps to show the user
        **************************************************************/
        
        // given intro steps that the user should review and consent to
        
        // and steps regarding login / security
        var securitySteps = loginSteps + [passcodeStep, healthDataStep]
        
        if config["Health Records"]?["Enabled"] as? Bool == true {
            securitySteps += [healthRecordsStep]
        }
        
        securitySteps += [completionStep]
        
        // guide the user through ALL steps
        let fullSteps = [reviewConsentStep] + securitySteps
        
        // unless they have already gotten as far as to enter an email address
        var stepsToUse = fullSteps
        if CKStudyUser.shared.email != nil {
            stepsToUse = securitySteps
        }
        
        /* **************************************************************
        * and SHOW the user these steps!
        **************************************************************/
        // create a task with each step

        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)
        
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
        let predicateRule = ORKPredicateStepNavigationRule(
            resultPredicates: [booleanAnswerType],
            destinationStepIdentifiers: ["RegistrationStep"],
            defaultStepIdentifier: "Passcode",
            validateArrays: true
        )
        
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")

        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController
    }
}
