//
//  CKUIHelper.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 10/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

// ONBOARDINGUI

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

        var loginSteps: [ORKStep]

        if config["Sign in with Apple"]["Enabled"] as? Bool == true {
            let signInWithAppleStep = CKSignInWithAppleStep(identifier: "SignInWithApple")
            loginSteps = [signInWithAppleStep]
        } else {
            let regexp = try! NSRegularExpression(pattern: "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}")

            let registerStep = ORKRegistrationStep(identifier: "RegistrationStep", title: "Registration", text: "Sign up for this study.", passcodeValidationRegularExpression: regexp, passcodeInvalidMessage: "Your password does not meet the following criteria: minimum 8 characters with at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character", options: [])

            let loginStep = ORKLoginStep(identifier: "LoginStep", title: "Login", text: "Log into this study.", loginViewControllerClass: LoginViewController.self)

            loginSteps = [registerStep, loginStep]
        }
        
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
        let emailVerificationSteps = loginSteps + [passcodeStep, healthDataStep, completionStep]
        
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

            switch step {
            case is CKHealthDataStep:
                // this step lets us run custom logic to ask for
                // HealthKit permissins when this step appears on screen.
                return CKHealthDataStepViewController(step: step)
            case is LoginCustomWaitStep:
                // run custom code to send an email for login!
                return LoginCustomWaitStepViewController(step: step)
            case is CKSignInWithAppleStep:
                // handle Sign in with Apple
                return CKSignInWithAppleStepViewController(step: step)
            default:
                return nil
            }
        }
    }
    
}

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

// STUDIESUI

public extension UIColor {
    class func greyText() -> UIColor {
        return UIColor(netHex: 0x989998)
    }
    
    class func lightWhite() -> UIColor {
        return UIColor(netHex: 0xf7f8f7)
    }
}

struct DocumentPreview: UIViewControllerRepresentable {
    private var isActive: Binding<Bool>
    private let viewController = UIViewController()
    private let docController: UIDocumentInteractionController

    init(_ isActive: Binding<Bool>, url: URL) {
        self.isActive = isActive
        self.docController = UIDocumentInteractionController(url: url)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPreview>) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DocumentPreview>) {
        if self.isActive.wrappedValue && docController.delegate == nil { // to not show twice
            docController.delegate = context.coordinator
            self.docController.presentPreview(animated: true)
        }
    }

    func makeCoordinator() -> Coordintor {
        return Coordintor(owner: self)
    }

    final class Coordintor: NSObject, UIDocumentInteractionControllerDelegate { // works as delegate
        let owner: DocumentPreview
        init(owner: DocumentPreview) {
            self.owner = owner
        }
        func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return owner.viewController
        }

        func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
            controller.delegate = nil // done, so unlink self
            owner.isActive.wrappedValue = false // notify external about done
        }
    }
}

struct PasscodeVC: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: ORKPasscodeViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKPasscodeViewController

    func makeUIViewController(context: Context) -> ORKPasscodeViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let num = config.read(query: "Passcode Type")
        
        if num == "4" {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType:.type4Digit)
            
            return editPasscodeViewController
        } else {
            let editPasscodeViewController = ORKPasscodeViewController.passcodeEditingViewController(withText: "", delegate: context.coordinator, passcodeType: .type6Digit)
            
            return editPasscodeViewController
        }
        
    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKPasscodeDelegate {
        func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        
        func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
            viewController.dismiss(animated: true, completion: nil)
        }
        

    }
    
}

struct TaskVC: UIViewControllerRepresentable {
    
    let vc: ORKTaskViewController
    
    init(tasks: ORKOrderedTask) {
        self.vc = ORKTaskViewController(task: tasks, taskRun: NSUUID() as UUID)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        
        if vc.outputDirectory == nil {
            vc.outputDirectory = context.coordinator.CKGetTaskOutputDirectory(vc)
        }
        
        self.vc.delegate = context.coordinator // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return self.vc

    }

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {

        }

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
               do {
                    // (1) convert the result of the ResearchKit task into a JSON dictionary
                    if let json = try CKTaskResultAsJson(taskViewController.result) {
                        
                        // (2) send using Firebase
                        try CKSendJSON(json)
                        
                        // (3) if we have any files, send those using Google Storage
                        if let associatedFiles = taskViewController.outputDirectory {
                            try CKSendFiles(associatedFiles, result: json)
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                fallthrough
            default:
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        }
        
        /**
        Create an output directory for a given task.
        You may move this directory.
         
         - Returns: URL with directory location
        */
        func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
            do {
                let defaultFileManager = FileManager.default
                
                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                
                return outputDirectory
            }
            catch let error as NSError {
                print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
            }
            
            return nil
        }
        
        /**
         Parse a result from a ResearchKit task and convert to a dictionary.
         JSON-friendly.

         - Parameters:
            - result: original `ORKTaskResult`
         - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
        */
        func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
            let jsonData = try ORKESerializer.jsonData(for: result)
            return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
        }
        
        /**
         Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
        */
        func CKSendJSON(_ json: [String:Any]) throws {
            
            if  let identifier = json["identifier"] as? String,
                let taskUUID = json["taskRunUUID"] as? String,
                let authCollection = CKStudyUser.shared.authCollection,
                let userId = CKStudyUser.shared.currentUser?.uid {
                
                let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
                
                // If using the CardinalKit GCP instance, the authCollection
                // represents the directory that you MUST write to in order to
                // verify and access this data in the future.
                
                let db = Firestore.firestore()
                db.collection(authCollection + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in
                    
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("Document successfully written!")
                    }
                }
                
            }
        }
        
        /**
         Given a file, use the Firebase SDK to store it in Google Storage.
        */
        func CKSendFiles(_ files: URL, result: [String:Any]) throws {
            if  let identifier = result["identifier"] as? String,
                let taskUUID = result["taskRunUUID"] as? String,
                let stanfordRITBucket = CKStudyUser.shared.authCollection {
                
                let fileManager = FileManager.default
                let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
                
                for file in fileURLs {
                    
                    var isDir : ObjCBool = false
                    guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                        continue //no file exists
                    }
                    
                    if isDir.boolValue {
                        try CKSendFiles(file, result: result) //cannot send a directory, recursively iterate into it
                        continue
                    }
                    
                    let storageRef = Storage.storage().reference()
                    let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")
                    
                    let uploadTask = ref.putFile(from: file, metadata: nil)
                    
                    uploadTask.observe(.success) { snapshot in
                        // TODO: better configurable feedback via something like:
                        // https://github.com/Daltron/NotificationBanner
                        print("File uploaded successfully!")
                    }
                    
                    uploadTask.observe(.failure) { snapshot in
                        print("Error uploading file!")
                        /*if let error = snapshot.error as NSError? {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                // File doesn't exist
                                break
                            case .unauthorized:
                                // User doesn't have permission to access file
                                break
                            case .cancelled:
                                // User canceled the upload
                                break
                                
                                /* ... */
                                
                            case .unknown:
                                // Unknown error occurred, inspect the server response
                                break
                            default:
                                // A separate error occurred. This is a good place to retry the upload.
                                break
                            }
                        }*/
                    }
                    
                }
            }
        }

    }
    
}


struct WithdrawalVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }


    typealias UIViewControllerType = ORKTaskViewController

    func makeUIViewController(context: Context) -> ORKTaskViewController {

        let config = CKPropertyReader(file: "CKConfiguration")
        
        let instructionStep = ORKInstructionStep(identifier: "WithdrawlInstruction")
        instructionStep.title = NSLocalizedString(config.read(query: "Withdrawal Instruction Title"), comment: "")
        instructionStep.text = NSLocalizedString(config.read(query: "Withdrawal Instruction Text"), comment: "")
        
        let completionStep = ORKCompletionStep(identifier: "Withdraw")
        completionStep.title = NSLocalizedString(config.read(query: "Withdraw Title"), comment: "")
        completionStep.text = NSLocalizedString(config.read(query: "Withdraw Text"), comment: "")
        
        let withdrawTask = ORKOrderedTask(identifier: "Withdraw", steps: [instructionStep, completionStep])
        
        // wrap that task on a view controller
        let taskViewController = ORKTaskViewController(task: withdrawTask, taskRun: nil)
        
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
                UserDefaults.standard.set(false, forKey: "didCompleteOnboarding")
                
                do {
                    try Auth.auth().signOut()
                    
                    if (ORKPasscodeViewController.isPasscodeStoredInKeychain()) {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }
                    
                    taskViewController.dismiss(animated: true, completion: {
                        fatalError()
                    })
                    
                } catch {
                    print(error.localizedDescription)
                    Alerts.showInfo(title: "Error", message: error.localizedDescription)
                }
                
            default:
                
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
}
