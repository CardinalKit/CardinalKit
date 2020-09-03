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
    
    var onboardingElements: [OnboardingElement] = []
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    @State var showingDetail = false
    @State var showingStudyTasks = false
    
    init() {
        let onboardingData = config.readAny(query: "Onboarding") as! [[String:String]]
        
        
        self.color = Color(config.readColor(query: "Primary Color"))
        
        for data in onboardingData {
            self.onboardingElements.append(OnboardingElement(logo: data["Logo"]!, title: data["Title"]!, description: data["Description"]!))
        }
        
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if showingStudyTasks {
                StudiesUI()
            } else {
                Spacer()

                Text(config.read(query: "Team Name")).padding(.leading, 20).padding(.trailing, 20)
                Text(config.read(query: "Study Title"))
                 .foregroundColor(self.color)
                 .font(.system(size: 35, weight: .bold, design: .default)).padding(.leading, 20).padding(.trailing, 20)

                Spacer()

                PageView(self.onboardingElements.map { infoView(logo: $0.logo, title: $0.title, description: $0.description, color: self.color) })

                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingDetail.toggle()
                    }, label: {
                         Text("Join Study")
                            .padding(20).frame(maxWidth: .infinity)
                             .foregroundColor(.white).background(self.color)
                             .cornerRadius(15).font(.system(size: 20, weight: .bold, design: .default))
                    }).sheet(isPresented: $showingDetail, onDismiss: {
                         if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
                            self.showingStudyTasks = completed as! Bool
                         }
                    }, content: {
                        OnboardingVC()
                    })
                    Spacer()
                }
                
                Spacer()
            }
        }.onAppear(perform: {
            if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
               self.showingStudyTasks = completed as! Bool
            }
        })
        
    }
}

struct OnboardingVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

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
        let signature = consentDocument.signatures!.first!
        signature.title = "Patient"
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
        
        let regexp = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")
        
        let registerStep = ORKRegistrationStep(identifier: "RegistrationStep", title: "Registration", text: "Sign up for this study.", passcodeValidationRegularExpression: regexp, passcodeInvalidMessage: "Your password does not meet the following criteria: minimum 8 characters with at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character", options: .init())
        
        let loginStep = ORKLoginStep(identifier: "LoginStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)
    
        
//        let loginStep = PasswordlessLoginStep(identifier: PasswordlessLoginStep.identifier)
//        let loginVerificationStep = LoginCustomWaitStep(identifier: LoginCustomWaitStep.identifier)
        
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
        let introSteps = [consentStep, reviewConsentStep]
        
        // and steps regarding login / security
        let emailVerificationSteps = [registerStep, loginStep, passcodeStep, healthDataStep, completionStep]
        
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
        taskViewController.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return taskViewController

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
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
                        
                    var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
                    docURL = docURL?.appendingPathComponent("\(config.read(query: "Consent File Name")).pdf") as NSURL?
                    

                    do {
                        let url = docURL! as URL
                        try data?.write(to: url)
                        
                        UserDefaults.standard.set(url.path, forKey: "consentFormURL")
                        print(url.path)

                    } catch let error {

                        print(error.localizedDescription)
                    }
                }
                
                
                print("Login successful! task: \(taskViewController.task?.identifier ?? "(no ID)")")
                
                fallthrough
            default:
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)
            }
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
            
            // MARK: - Advanced Concepts
            // Sometimes we might want some custom logic
            // to run when a step appears 🎩
            
            if stepViewController.step?.identifier == PasswordlessLoginStep.identifier {
                
                /* **************************************************************
                * When the login step appears, asking for the patient's email
                **************************************************************/
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // if we already have an email, go forward and continue.
                    DispatchQueue.main.async {
                        stepViewController.goForward()
                    }
                }
                
            } else if (stepViewController.step?.identifier == "RegistrationStep") {
                
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // if we already have an email, go forward and continue.
                    DispatchQueue.main.async {
                        stepViewController.goForward()
                    }
                }
                
            } else if (stepViewController.step?.identifier == "LoginStep") {
                
                if let _ = CKStudyUser.shared.currentUser?.email {
                    // good — we have an email!
                } else {
                    let alert = UIAlertController(title: nil, message: "Creating account...", preferredStyle: .alert)

                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    loadingIndicator.startAnimating();

                    alert.view.addSubview(loadingIndicator)
                    taskViewController.present(alert, animated: true, completion: nil)
                    
                    let stepResult = taskViewController.result.stepResult(forStepIdentifier: "RegistrationStep")
                    if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                        if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                            DispatchQueue.main.async {
                                Auth.auth().createUser(withEmail: email, password: pass) { (res, error) in
                                    DispatchQueue.main.async {
                                        if error != nil {
                                            alert.dismiss(animated: true, completion: nil)
                                            if let errCode = AuthErrorCode(rawValue: error!._code) {

                                                switch errCode {
                                                    default:
                                                        let alert = UIAlertController(title: "Registration Error!", message: error?.localizedDescription, preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                                                        taskViewController.present(alert, animated: true)
                                                }
                                            }
                                            
                                            stepViewController.goBackward()

                                        } else {
                                            alert.dismiss(animated: true, completion: nil)
                                            print("Created user!")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else if (stepViewController.step?.identifier == "Passcode") {

                let alert = UIAlertController(title: nil, message: "Logging in...", preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();

                alert.view.addSubview(loadingIndicator)
                taskViewController.present(alert, animated: true, completion: nil)
                
                let stepResult = taskViewController.result.stepResult(forStepIdentifier: "LoginStep")
                if let emailRes = stepResult?.results?.first as? ORKTextQuestionResult, let email = emailRes.textAnswer {
                    if let passwordRes = stepResult?.results?[1] as? ORKTextQuestionResult, let pass = passwordRes.textAnswer {
                        Auth.auth().signIn(withEmail: email, password: pass) { (res, error) in
                            DispatchQueue.main.async {
                                if error != nil {
                                    alert.dismiss(animated: true, completion: nil)
                                    if let errCode = AuthErrorCode(rawValue: error!._code) {

                                        switch errCode {
                                            default:
                                                let alert = UIAlertController(title: "Login Error!", message: error?.localizedDescription, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

                                                taskViewController.present(alert, animated: true)
                                        }
                                    }
                                    
                                    stepViewController.goBackward()

                                } else {
                                    alert.dismiss(animated: true, completion: nil)
                                    print("successfully signed in!")
                                }
                            }
                        }
                    }
                }

                
            } else if stepViewController.step?.identifier == LoginCustomWaitStep.identifier {
                
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
                .padding(6).overlay(
                    Text(logo).foregroundColor(.white).font(.system(size: 42, weight: .light, design: .default))
                )

            Text(title).font(.title)
            
            Text(description).font(.body).multilineTextAlignment(.center).padding(.leading, 40).padding(.trailing, 40)
            
            
        }
    }
}

// PAGE VIEW CONTROLLER

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        let config = CKPropertyReader(file: "CKConfiguration")
        control.numberOfPages = numberOfPages
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = config.readColor(query: "Primary Color")
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @State var currentPage = 0
    init(_ views: [Page]) {
        self.viewControllers = views.map { UIHostingController(rootView: $0) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(controllers: viewControllers, currentPage: $currentPage)
            PageControl(numberOfPages: viewControllers.count, currentPage: $currentPage)
        }
    }
}

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
        [self.controllers[self.currentPage]], direction: .forward, animated: true)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return parent.controllers.last
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return parent.controllers.first
            }
            return parent.controllers[index + 1]
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.currentPage = index
            }
        }
    }
}



struct OnboardingUI_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingUI()
    }
}
