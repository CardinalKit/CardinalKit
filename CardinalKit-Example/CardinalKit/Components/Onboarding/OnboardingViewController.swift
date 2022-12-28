//
//  OnboardingViewController.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit framework.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import Firebase
import ResearchKit
import SwiftUI
import UIKit

/// Onboarding workflow for new users.
struct OnboardingViewController: UIViewControllerRepresentable {
    func makeCoordinator() -> OnboardingViewCoordinator {
        OnboardingViewCoordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}

    // swiftlint:disable function_body_length
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let config = CKPropertyReader(file: "CKConfiguration")

        /// Ask user to review, then sign consent form.
        let consentDocument = ConsentDocument()
        let signature = consentDocument.signatures?.first
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")

        /// Get permission to collect health data from HealthKit.
        let healthDataStep = CKHealthDataStep(identifier: "Healthkit")
        
        /// Get permission to collect health records from HealthKit.
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")
        
        /// Ask the user to sign up using Apple Sign In, Google Sign In, or their email address.
        var loginSteps: [ORKStep]

        /// First, we create a step that allows users to choose their sign in method.
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")

        /// Then, we create a step that allow users to sign up with their email address.

        /// Text shown on the email & password registration screen
        let registrationText = """
        Sign up for this study using your email address.

        Your password should contain a minimum of 8 characters \
        with at least 1 uppercase, 1 lowercase, 1 number, and 1 special character.

        """

        /// Regular expression that defines the password criteria
        let regexp = try? NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")

        /// Error message shown if the password the user entered does not meet criteria
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

        /// Now, we combine these steps into an array
        loginSteps = [signInButtons, registerStep, loginStep]
        
        /// Ask the user to create a security passcode that will be used to access the app
        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") // NOTE: requires NSFaceIDUsageDescription in info.plist
        let type = config.read(query: "Passcode Type")
        if type == "6" {
            passcodeStep.passcodeType = .type6Digit
        } else {
            passcodeStep.passcodeType = .type4Digit
        }
        passcodeStep.text = config.read(query: "Passcode Text")
        
        /// Inform the user that they are done with onboarding
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = config.read(query: "Completion Step Title")
        completionStep.text = config.read(query: "Completion Step Text")
        
        /// Create an array with the steps to show users
        var onboardingSteps: [ORKStep] = []

        /// Add consent steps
        onboardingSteps.append(reviewConsentStep)

        /// Add login steps
        onboardingSteps += loginSteps

        /// Add passcode step
        onboardingSteps.append(passcodeStep)

        /// Add steps for requesting permission for health data access
        onboardingSteps.append(healthDataStep)
        if config["Health Records"]?["Enabled"] as? Bool == true {
            onboardingSteps.append(healthRecordsStep)
        }

        /// Add completion step
        onboardingSteps.append(completionStep)

        /// Create a ResearchKit task from the array of steps
        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyOnboardingTask", steps: onboardingSteps)

        /// Create a navigation rule for the sign in screen that will show
        /// the email/password sign up workflow if the user chose it,
        /// otherwise skips forward to the passcode entry screen.
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(
            with: resultSelector,
            expectedAnswer: true
        )
        let predicateRule = ORKPredicateStepNavigationRule(
            resultPredicates: [booleanAnswerType],
            destinationStepIdentifiers: ["RegistrationStep"],
            defaultStepIdentifier: "Passcode",
            validateArrays: true
        )
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")

        /// Present the task to the user
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate`
        return taskViewController
    }
}
