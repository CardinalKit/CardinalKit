//
//  OnboardingUI.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

struct OnboardingElement {
    let logo: String
    let title: String
    let description: String
}

struct OnboardingUI: View {
    var onboardingElements: [OnboardingElement] {
        let onboardingData = config.readAny(query: "Onboarding") as! [[String:String]]
        return onboardingData.map { data in
            OnboardingElement(
                logo: data["Logo"]!,
                title: data["Title"]!,
                description: data["Description"]!
            )
        }
    }
    var color: Color {
        return config.readColor(query: "Primary Color")
    }
    @EnvironmentObject var config: CKPropertyReader
    @State var showingDetail = false
    @State var showingStudyTasks = false

    var body: some View {
        VStack(spacing: 10) {
            if showingStudyTasks {
                StudiesUI()
                    .environmentObject(NotificationsAndResults())
            } else {
                Spacer()

                Text(config.read(query: "Team Name"))
                    .padding(.horizontal)
                Text(config.read(query: "Study Title"))
                    .foregroundColor(color)
                    .font(.title)
                    .padding(.horizontal)

                Spacer()

                PageView(onboardingElements.map {
                    infoView(logo: $0.logo,
                             title: $0.title,
                             description: $0.description,
                             color: self.color)
                })

                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingDetail.toggle()
                    }, label: {
                        Text("Join Study")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(color)
                            .cornerRadius(15)
                            .font(.system(size: 20, weight: .bold, design: .default))
                    })
                    .sheet(isPresented: $showingDetail, onDismiss: {
                        self.showingStudyTasks = UserDefaults.standard.bool(forKey: "didCompleteOnboarding")
                    }, content: {
                        OnboardingVC()
                            .environmentObject(self.config)
                    })
                    
                    Spacer()
                }
                
                Spacer()
            }
        }.onAppear {
            self.showingStudyTasks = UserDefaults.standard.bool(forKey: "didCompleteOnboarding")
        }
    }
}

enum EnrollMethods: NSString, CustomStringConvertible, CaseIterable {
    case signUp
    case login
    case signInWithApple

    var description: String {
        switch self {
        case .login:
            return "Login with Email and Password"
        case .signInWithApple:
            return "Sign in with Apple"
        case .signUp:
            return "Sign Up"
        }
    }
}

struct OnboardingVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController

    @EnvironmentObject var config: CKPropertyReader

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        /* **************************************************************
         * MARK: - STEP (1): get user consent
         **************************************************************/
        // use the `ORKVisualConsentStep` from ResearchKit
        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        
        /* **************************************************************
         * MARK: - STEP (2): ask user to review and sign consent document
         **************************************************************/
        // use the `ORKConsentReviewStep` from ResearchKit
        let signature = consentDocument.signatures!.first!
        signature.title = "Patient"
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = config.read(query: "Review Consent Step Text")
        reviewConsentStep.reasonForConsent = config.read(query: "Reason for Consent Text")
        
        /* **************************************************************
         * MARK: - STEP (3): get permission to collect HealthKit data, read-only
         **************************************************************/
        // see `HealthDataStep` to configure!
        let healthDataStep = CKHealthDataStep(identifier: "Health")

        
        /* **************************************************************
         * MARK: - STEP (4): ask user to enter their email address for login
         **************************************************************/
        // the `LoginStep` collects and email address, and
        // the `LoginCustomWaitStep` waits for email verification.

        let chooseEnrollMethodStep = ORKQuestionStep(
            identifier: "Enroll",
            title: "Enroll",
            question: "Please choose a sign-in method",
            answer: .choiceAnswerFormat(with: .singleChoice, textChoices: EnrollMethods.allCases.map {
                ORKTextChoice(text: $0.description, value: $0.rawValue)
            })
        )
        
        let regexp = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")
        
        let registerStep = ORKRegistrationStep(identifier: "RegistrationStep", title: "Registration", text: "Sign up for this study.", passcodeValidationRegularExpression: regexp, passcodeInvalidMessage: "Your password does not meet the following criteria: minimum 8 characters with at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character", options: [])


        let loginStep = ORKLoginStep(identifier: "LoginStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)

        let signInWithAppleStep = CKSignInWithAppleStep(
            identifier: "SignInWithApple",
            title: "Sign in with Apple",
            text: "The fast, easy way to sign in. All accounts are protected with two-factor authentication for superior security, and Apple will not track your activity in your app or website.",
            requestedScopes: [.email]
        )

        // let loginStep = PasswordlessLoginStep(identifier: PasswordlessLoginStep.identifier)
        // let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
        
        /* **************************************************************
         *  MARK: - STEP (5): ask the user to create a security passcode
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
         * MARK: - STEP (6): inform the user that they are done with sign-up!
         **************************************************************/
        // use the `ORKCompletionStep` from ResearchKit
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = config.read(query: "Completion Step Title")
        completionStep.text = config.read(query: "Completion Step Text")
        
        /* **************************************************************
         * MARK: - Finally, CREATE an array with the steps to show the user
         **************************************************************/
        
        // given intro steps that the user should review and consent to
        let introSteps = [consentStep, reviewConsentStep]
        
        // and steps regarding login / security
        let emailVerificationSteps = [
            chooseEnrollMethodStep, registerStep, loginStep, signInWithAppleStep,
            passcodeStep, healthDataStep, completionStep
        ]

        // let stepsToUse = true // DEBUG ONLY
        let stepsToUse = CKStudyUser.shared.email != nil
            ? emailVerificationSteps // receive magic link
            : introSteps + emailVerificationSteps  // guide the user through ALL steps

        /* **************************************************************
         * and SHOW the user these steps!
         **************************************************************/
        // create a task with each step
        let orderedTask = ORKNavigableOrderedTask(identifier: "StudyOnboardingTask", steps: stepsToUse)

        let toPasscode = ORKDirectStepNavigationRule(destinationStepIdentifier: passcodeStep.identifier)
        orderedTask.setNavigationRule(toPasscode, forTriggerStepIdentifier: registerStep.identifier)
        orderedTask.setNavigationRule(toPasscode, forTriggerStepIdentifier: loginStep.identifier)
        orderedTask.setNavigationRule(toPasscode, forTriggerStepIdentifier: signInWithAppleStep.identifier)

        let enrollMethodResultSelector = ORKResultSelector(resultIdentifier: chooseEnrollMethodStep.identifier)
        let toRegister = ORKResultPredicate
            .predicateForChoiceQuestionResult(with: enrollMethodResultSelector,
                                              expectedAnswerValue: EnrollMethods.signUp.rawValue)
        let toLogin = ORKResultPredicate
            .predicateForChoiceQuestionResult(with: enrollMethodResultSelector,
                                              expectedAnswerValue: EnrollMethods.login.rawValue)
        let toSignInWithApple = ORKResultPredicate
            .predicateForChoiceQuestionResult(with: enrollMethodResultSelector,
                                              expectedAnswerValue: EnrollMethods.signInWithApple.rawValue)

        let toAppropriateEnrollMethod = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [
            (toRegister, registerStep.identifier),
            (toLogin, loginStep.identifier),
            (toSignInWithApple, signInWithAppleStep.identifier)
        ])
        orderedTask.setNavigationRule(toAppropriateEnrollMethod, forTriggerStepIdentifier: chooseEnrollMethodStep.identifier)

        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: orderedTask, taskRun: nil)
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController
    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

    }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController,
                                       didFinishWith reason: ORKTaskViewControllerFinishReason,
                                       error: Error?) {
            switch reason {
            case .completed:
                // if we completed the onboarding task view controller, go to study.
                // performSegue(withIdentifier: "unwindToStudy", sender: nil)
                
                // TODO: where to go next?
                // trigger "Studies UI"
                UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                
                let signatureResult = taskViewController.result.stepResult(forStepIdentifier: "ConsentReviewStep")?.results?.first as! ORKConsentSignatureResult
                
                let consentDocument = ConsentDocument()
                signatureResult.apply(to: consentDocument)

                consentDocument.makePDF { (data, error) -> Void in
                    let config = CKPropertyReader(file: "CKConfiguration")

                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
                        .appendingPathComponent("\(config.read(query: "Consent File Name")).pdf")

                    do {
                        try data?.write(to: url)
                        try UserDefaults.standard.set(url.bookmarkData(), forKey: "consentFormURL")
                        print(url.path)
                    } catch {
                        print(error.localizedDescription)
                    }
                }

                print("Login successful! task: \(taskViewController.task?.identifier ?? "(no ID)")")
            default:
                break
            }
            taskViewController.dismiss(animated: true, completion: nil)
        }

        func taskViewController(_ taskViewController: ORKTaskViewController,
                                stepViewControllerWillDisappear stepViewController: ORKStepViewController,
                                navigationDirection direction: ORKStepViewControllerNavigationDirection) {
            guard case .forward = direction else {
                return
            }

            func showAlert(titled title: String) -> UIAlertController {
                let alert = UIAlertController(title: nil, message: title, preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = .medium
                loadingIndicator.startAnimating()

                alert.view.addSubview(loadingIndicator)
                taskViewController.present(alert, animated: true, completion: nil)

                return alert
            }

            // Avoid conflict with pushing new step on top
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                switch stepViewController.step?.identifier {
                case "RegistrationStep":
                    let alert = showAlert(titled: "Creating account...")
                    let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
                    if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer,
                       let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        Auth.auth().createUser(withEmail: email, password: pass) { (_, error) in
                            func showError(_ error: Error, title: String) {
                                let newAlert = UIAlertController(title: title,
                                                              message: error.localizedDescription,
                                                              preferredStyle: .alert)
                                newAlert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                                    taskViewController.goBackward()
                                })
                                alert.dismiss(animated: true) {
                                    taskViewController.present(newAlert, animated: true)
                                }
                            }

                            if let error = error, error._code != AuthErrorCode.emailAlreadyInUse.rawValue {
                                showError(error, title: "Registration Error!")
                            } else {
                                Auth.auth().signIn(withEmail: email, password: pass) { (_, error) in
                                    if let error = error {
                                        showError(error, title: "Sign-in Error!")
                                    } else {
                                        alert.dismiss(animated: true, completion: nil)
                                        print("successfully signed in!")
                                    }
                                }
                            }
                        }
                    }
                case "LoginStep":
                    let alert = showAlert(titled: "Logging in...")
                    let stepResult = taskViewController.result.stepResult(forStepIdentifier: "LoginStep")
                    if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer,
                       let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        Auth.auth().signIn(withEmail: email, password: pass) { (_, error) in
                            alert.dismiss(animated: true) {
                                guard let error = error else {
                                    return print("successfully signed in!")
                                }
                                let alert = UIAlertController(title: "Login Error!", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                                    taskViewController.goBackward()
                                })
                                taskViewController.present(alert, animated: true)
                            }
                        }
                    }
                default:
                    break
                }
            }
        }

        func taskViewController(_ taskViewController: ORKTaskViewController,
                                stepViewControllerWillAppear stepViewController: ORKStepViewController) {
            // MARK: - Advanced Concepts
            // Sometimes we might want some custom logic
            // to run when a step appears 🎩

            switch stepViewController.step?.identifier {
            case LoginCustomWaitStep.identifier:
                /* **************************************************************
                 * When the email verification step appears, send email in background!
                 **************************************************************/

                let stepResult = taskViewController.result.stepResult(forStepIdentifier: PasswordlessLoginStep.identifier)
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
            default:
                return
            }
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController,
                                viewControllerFor step: ORKStep) -> ORKStepViewController? {
            // MARK: - Advanced Concepts
            // Overriding the view controller of an ORKStep
            // lets us run our own code on top of what
            // ResearchKit already provides!
            switch step {
            case is CKHealthDataStep:
                // this step lets us run custom logic to ask for
                // HealthKit permissins when this step appears on screen.
                return CKHealthDataStepViewController(step: step)
            case is LoginCustomWaitStep:
                // run custom code to send an email for login!
                return LoginCustomWaitStepViewController(step: step)
            case is CKSignInWithAppleStep:
                return CKSignInWithAppleStepViewController(step: step)
            default:
                return nil
            }
        }

        func taskViewController(_ taskViewController: ORKTaskViewController,
                                hasLearnMoreFor step: ORKStep) -> Bool {
            // Indicates the step should display learn more button.
            if step is CKSignInWithAppleStep {
                return true
            }
            return false
        }

        func taskViewController(_ taskViewController: ORKTaskViewController,
                                learnMoreForStep stepViewController: ORKStepViewController) {
            // Presents the "How to use Sign in with Apple" guide.
            if stepViewController is CKSignInWithAppleStepViewController {
                UIApplication.shared.open(URL(string: "https://support.apple.com/HT210318")!)
            }
        }
    }
}

struct infoView: View {
    let logo: String
    let title: String
    let description: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 100, height: 100, alignment: .center)
                .padding(6)
                .overlay(
                    Text(logo)
                        .foregroundColor(.white)
                        .font(.system(size: 42, weight: .light, design: .default))
                )

            Text(title)
                .font(.title)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct OnboardingUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingUI()
    }
}
