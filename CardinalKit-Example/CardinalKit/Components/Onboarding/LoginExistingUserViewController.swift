//
//  LoginViewController.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit framework.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Firebase
import ResearchKit
import SwiftUI
import UIKit

/// Onboarding workflow for users who have an existing account.
struct LoginExistingUserViewController: UIViewControllerRepresentable {
    func makeCoordinator() -> OnboardingViewCoordinator {
        OnboardingViewCoordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}

    // swiftlint:disable function_body_length
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let config = CKPropertyReader(file: "CKConfiguration")

        /* **************************************************************
         *  STEP (1): Ask the user to log in
         **************************************************************/
        var loginSteps: [ORKStep]
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")
        let loginUserPassword = ORKLoginStep(
            identifier: "LoginExistingStep",
            title: "Login",
            text: "Log into this study.",
            loginViewControllerClass: LoginViewController.self
        )
        loginSteps = [signInButtons, loginUserPassword]

        /* **************************************************************
         *  STEP (2): Ask user to sign consent form (if not found in cloud storage)
         **************************************************************/
        let consentDocument = ConsentDocument()
        let signature = consentDocument.signatures?.first
        let reviewConsentStep = ORKConsentReviewStep(
            identifier: "ConsentReviewStep",
            signature: signature,
            in: consentDocument
        )
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        let consentReview = CKReviewConsentDocument(identifier: "ConsentReview")

        /* **************************************************************
         *  STEP (3): Get permission to collect HealthKit data
         **************************************************************/
        let healthDataStep = CKHealthDataStep(identifier: "HealthKit")

        /* **************************************************************
         *  STEP (3.5): Get permission to collect Health Records data
         **************************************************************/
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")

        /* **************************************************************
        *  STEP (4): ask the user to create a security passcode
        *  that will be required to use this app!
        *****************************************************************/
        // set passcode
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")

        /* **************************************************************
        * STEP (5): Create an array with the steps to show new users.
        *****************************************************************/
        var existingUserOnboardingSteps: [ORKStep] = []

        // Add login steps
        existingUserOnboardingSteps += loginSteps

        // Add consent steps
        existingUserOnboardingSteps += [consentReview, reviewConsentStep]

        // Add steps for requesting permissions for health data access
        existingUserOnboardingSteps.append(healthDataStep)
        if config["Health Records"]?["Enabled"] as? Bool == true {
            loginSteps += [healthRecordsStep]
        }

        // Add passcode step
        existingUserOnboardingSteps += [passcodeStep]

        /* **************************************************************
        * STEP (6): Create a ResearchKit task from the array of steps.
        *****************************************************************/
        // Create a navigation rule for the sign in screen that will show
        // the email/password workflow if the user chose it,
        // otherwise skips forward to consent.
        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyLoginTask", steps: loginSteps)
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: resultSelector,
            expectedAnswer: true
        )
        let predicateRule = ORKPredicateStepNavigationRule(
            resultPredicates: [booleanAnswerType],
            destinationStepIdentifiers: ["LoginExistingStep"],
            defaultStepIdentifier: "ConsentReview",
            validateArrays: true
        )
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")

        // Create a navigation rule that checks if the user has previously signed
        // a consent document - if so, they are redirected to the HealthKit permissions
        // step, else they are shown the consent document to sign.
        let resultConsent = ORKResultSelector(resultIdentifier: "ConsentReview")
        let booleanAnswerConsent = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: resultConsent,
            expectedAnswer: true
        )
        let predicateRuleConsent = ORKPredicateStepNavigationRule(
            resultPredicates: [booleanAnswerConsent],
            destinationStepIdentifiers: ["HealthKit"],
            defaultStepIdentifier: "ConsentReviewStep",
            validateArrays: true
        )
        navigableTask.setNavigationRule(predicateRuleConsent, forTriggerStepIdentifier: "ConsentReview")

        /* **************************************************************
        * STEP (7): Present the task to the user
        **************************************************************/
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator
        return taskViewController
    }
}
