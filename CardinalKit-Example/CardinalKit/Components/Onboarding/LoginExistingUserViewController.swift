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

    // We disable the body length rule because this function is readable
    // swiftlint:disable function_body_length
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let config = CKPropertyReader(file: "CKConfiguration")

        /// Ask the user to log in, either via social accounts, or email.
        var loginSteps: [ORKStep]
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")
        let loginUserPassword = ORKLoginStep(
            identifier: "LoginExistingStep",
            title: "Login",
            text: "Log into this study.",
            loginViewControllerClass: CKLoginStepViewController.self
        )
        loginSteps = [signInButtons, loginUserPassword]

        /// Ask the user to sign the consent form (if not already present in cloud storage)
        let consentDocument = ConsentDocument()
        let signature = consentDocument.signatures?.first
        let reviewConsentStep = ORKConsentReviewStep(
            identifier: "ConsentReviewStep",
            signature: signature,
            in: consentDocument
        )
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        let verifyConsentStep = CKVerifyConsentDocument(identifier: "VerifyConsentStep")

        /// Get permission to collect health data from HealthKit
        let healthDataStep = CKHealthDataStep(identifier: "HealthKit")

        /// Get permission to collect health records from HealthKit
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")

        /// Ask the user to create a security passcode which will be used to open the app
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode")
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")

        /// Create an array with the steps to show users
        var existingUserOnboardingSteps: [ORKStep] = []

        /// Add login steps
        existingUserOnboardingSteps += loginSteps

        /// Add consent steps
        existingUserOnboardingSteps += [verifyConsentStep, reviewConsentStep]

        /// Add steps for requesting permissions for health data access
        existingUserOnboardingSteps += [healthDataStep]

        if config["Health Records"]?["Enabled"] as? Bool == true {
            existingUserOnboardingSteps += [healthRecordsStep]
        }

        /// Add passcode step
        existingUserOnboardingSteps += [passcodeStep]

        /// Create a ResearchKit task from the array of steps
        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyLoginTask", steps: existingUserOnboardingSteps)

        /// Create a navigation rule for the sign in screen that will show the email/password workflow if the user chose it,
        /// otherwise skips forward to the verify consent step.
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: resultSelector,
            expectedAnswer: true
        )
        let predicateRule = ORKPredicateStepNavigationRule(
            resultPredicates: [booleanAnswerType],
            destinationStepIdentifiers: ["LoginExistingStep"],
            defaultStepIdentifier: "VerifyConsentStep",
            validateArrays: true
        )
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")

        /// Create a navigation rule that checks if the user has previously signed a consent document.
        /// If they have, direct to the HealthKit permissions step, else show the consent document to sign.
        let resultConsent = ORKResultSelector(resultIdentifier: "VerifyConsentStep")
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

        /// Present the task to the user
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator
        return taskViewController
    }
}
