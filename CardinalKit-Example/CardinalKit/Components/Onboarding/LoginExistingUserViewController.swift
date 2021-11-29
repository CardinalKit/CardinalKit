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
        var loginSteps: [ORKStep]
        let signInButtons = CKMultipleSignInStep(identifier: "SignInButtons")
        let loginUserPassword = ORKLoginStep(identifier: "LoginExistingStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)
        loginSteps = [signInButtons, loginUserPassword]
        
//        if config["Login-Sign-In-With-Apple"]["Enabled"] as? Bool == true {
//            let signInWithAppleStep = CKSignInWithAppleStep(identifier: "SignExistingInWithApple")
//            loginSteps = [signInWithAppleStep]
//        } else {
//            let loginStep = ORKLoginStep(identifier: "LoginExistingStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)
//
//            loginSteps = [loginStep]
//        }
        
//        // use the `ORKPasscodeStep` from ResearchKit.
//        let passcodeStep = ORKPasscodeStep(identifier: "Passcode") //NOTE: requires NSFaceIDUsageDescription in info.plist
//        let type = config.read(query: "Passcode Type")
//        if type == "6" {
//            passcodeStep.passcodeType = .type6Digit
//        } else {
//            passcodeStep.passcodeType = .type4Digit
//        }
//        passcodeStep.text = config.read(query: "Passcode Text")
        
        // set health data permissions
        let healthDataStep = CKHealthDataStep(identifier: "HealthKit")
        let healthRecordsStep = CKHealthRecordsStep(identifier: "HealthRecords")
        
        // create a task with each step
        loginSteps += [healthDataStep, healthRecordsStep]
        let navigableTask = ORKNavigableOrderedTask(identifier: "StudyLoginTask", steps: loginSteps)
//        let orderedTask = ORKOrderedTask(identifier: "StudyLoginTask", steps: loginSteps)
        let resultSelector = ORKResultSelector(resultIdentifier: "SignInButtons")
        let booleanAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicates: [booleanAnswerType],
                                                           destinationStepIdentifiers: ["LoginExistingStep"],
                                                           defaultStepIdentifier: "HealthKit",
                                                           validateArrays: true)
        navigableTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: "SignInButtons")
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: navigableTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController
    }
    
}

