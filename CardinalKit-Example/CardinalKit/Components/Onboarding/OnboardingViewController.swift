//
//  OnboardingViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

struct OnboardingViewController: UIViewControllerRepresentable {
    
    func makeCoordinator() -> OnboardingViewCoordinator {
        OnboardingViewCoordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}
    func makeUIViewController(context: Context) -> ORKTaskViewController {

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
        if config["Login-Sign-In-With-Apple"]["Enabled"] as? Bool == true {
            let signInWithAppleStep = CKSignInWithAppleStep(identifier: "SignInWithApple")
            loginSteps = [signInWithAppleStep]
        } else if config.readBool(query: "Login-Passwordless") == true {
            let loginStep = PasswordlessLoginStep(identifier: PasswordlessLoginStep.identifier)
            let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
            
            loginSteps = [loginStep, loginVerificationStep]
        } else {
            let regexp = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")

            let registerStep = ORKRegistrationStep(identifier: "RegistrationStep", title: "Registration", text: "Sign up for this study.", passcodeValidationRegularExpression: regexp, passcodeInvalidMessage: "Your password does not meet the following criteria: minimum 8 characters with at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character", options: [])

            let loginStep = ORKLoginStep(identifier: "LoginStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)

            loginSteps = [registerStep, loginStep]
        }
        
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
        completionStep.title = config.read(query: "Completion Step Title")
        completionStep.text = config.read(query: "Completion Step Text")
        
        /* **************************************************************
        * finally, CREATE an array with the steps to show the user
        **************************************************************/
        
        // given intro steps that the user should review and consent to
        let introSteps: [ORKStep] = [consentStep, reviewConsentStep]
        
        // and steps regarding login / security
        let emailVerificationSteps = loginSteps + [passcodeStep]
        
        var onbardingSurveySteps = [ORKStep]()
        let answerFormatEmail = ORKAnswerFormat.emailAnswerFormat()
                let stringAnswerFormat = ORKTextAnswerFormat()
                let numberAnswerFormat = ORKNumericAnswerFormat(style: .integer, unit: nil, minimum: 18 as NSNumber, maximum: 100 as NSNumber)

                // Question 1 is getting name, email, and age
                let AboutYouFormItem = ORKFormItem(sectionTitle: "Personal information")
                let firstNameFormItem = ORKFormItem(identifier: "RegistrationForm-FirstName", text: "First Name", answerFormat: stringAnswerFormat)
                let lastNameFormItem = ORKFormItem(identifier: "RegistrationForm-LastName", text: "Last Name", answerFormat: stringAnswerFormat)
                let ageFromItem = ORKFormItem(identifier: "RegistrationForm-Age", text: "Age", answerFormat: numberAnswerFormat)
                let emailFormItem = ORKFormItem(identifier: "RegistrationForm-Email", text: "Email", answerFormat: answerFormatEmail)
                // registration form
                let formStep = ORKFormStep(identifier: "RegistrationForm", title: "About you", text: "Before we get started, tell us a little bit about yourself")
                formStep.formItems = [AboutYouFormItem, firstNameFormItem, lastNameFormItem, ageFromItem, emailFormItem]
        onbardingSurveySteps += [formStep]

                // Question 2 is asking about skin type (oily, combination, dry)
                let skinTypes = [
                  ORKTextChoice(text: "Oily", value: 0 as NSNumber),
                  ORKTextChoice(text: "Combination", value: 1 as NSNumber),
                  ORKTextChoice(text: "Dry", value: 2 as NSNumber)
                ]
                let skinTypeAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: skinTypes)
                let skinTypeQuestionStep = ORKQuestionStep(identifier: "SkinTypeQuestionStep", title: "Skin Type", question: "How would you describe your skin?", answer: skinTypeAnswerFormat)
        onbardingSurveySteps += [skinTypeQuestionStep]

                // Question 3 is aking about main concern (clogged pores, control breakouts, acne scars)
                let skinIssues = [
                  ORKTextChoice(text: "Control breakouts", value: 0 as NSNumber),
                  ORKTextChoice(text: "Clean clogged pores", value: 1 as NSNumber),
                  ORKTextChoice(text: "Reduce acne scars", value: 2 as NSNumber),
                  ORKTextChoice(text: "Fade dark spots", value: 3 as NSNumber),
                  ORKTextChoice(text: "Fight wrinkles", value: 4 as NSNumber),
                  ORKTextChoice(text: "Reduce fine lines", value: 5 as NSNumber),
                ]
                let skinConcernAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: skinIssues)
                let skinIssuesQuestionStep = ORKQuestionStep(identifier: "SkinIssuesQuestionStep", title: "Goals", question: "What would you like to improve about your skin?", answer: skinConcernAnswerFormat)
        onbardingSurveySteps += [skinIssuesQuestionStep]

                // Question 4 is asking about allergies
                let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
                let booleanStep = ORKQuestionStep(identifier: "Allergies-Boolean", title: "Allergies", question: "Do you have any allergies?", answer: booleanAnswer)
                booleanStep.isOptional = true
        onbardingSurveySteps += [booleanStep]

                // if yes then we ask the user to enter them in a text box
                let allergiesAnswerFormat = ORKTextAnswerFormat(maximumLength: 200)
                allergiesAnswerFormat.multipleLines = true
                let allergiesQuestionStep = ORKQuestionStep(identifier: "AllergiesQuestionStep", title: "Allergies", question: "Please describe your allergies.", answer: allergiesAnswerFormat)
        onbardingSurveySteps += [allergiesQuestionStep]

                // Question 5 is asking to upload a photo
                let instructionStep = ORKInstructionStep(identifier: "imageCaptureInstructionStep")
                instructionStep.title = NSLocalizedString("Time to take a selfie", comment: "")
                instructionStep.text = "Please take a photo of yourself, position your face as indicated and make sure you have good lighting."
        let handSolidImage = UIImage(systemName: "person.fill")!
                instructionStep.image = handSolidImage.withRenderingMode(.alwaysTemplate)
                instructionStep.isOptional = false
                let imageCaptureStep = ORKImageCaptureStep(identifier: "imageCaptureStep")
                imageCaptureStep.title = NSLocalizedString("Image Capture", comment: "")
                imageCaptureStep.isOptional = true
                imageCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the image", comment: "")
                imageCaptureStep.accessibilityHint = NSLocalizedString("Captures the image visible in the preview", comment: "")

                imageCaptureStep.templateImage = UIImage(systemName: "person.fill")!

                imageCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
        onbardingSurveySteps += [instructionStep, imageCaptureStep]

        // guide the user through ALL steps
        let fullSteps = introSteps + emailVerificationSteps + onbardingSurveySteps + [completionStep]
        
        // unless they have already gotten as far as to enter an email address
        var stepsToUse = fullSteps
        if CKStudyUser.shared.email != nil {
            stepsToUse = emailVerificationSteps
        }
        
        /* **************************************************************
        * and SHOW the user these steps!
        **************************************************************/
        // create navigable rule for allergy question
        let resultBooleanSelector = ORKResultSelector(resultIdentifier: booleanStep.identifier)
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultBooleanSelector, expectedAnswer: false)
        let navigableRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(resultPredicate: predicate, destinationStepIdentifier: instructionStep.identifier)])
               
        // create a task with each step
        let orderedTask = ORKNavigableOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        orderedTask.setNavigationRule(navigableRule, forTriggerStepIdentifier: booleanStep.identifier)
        
        // & present the VC!
        return taskViewController
    }
    
}
