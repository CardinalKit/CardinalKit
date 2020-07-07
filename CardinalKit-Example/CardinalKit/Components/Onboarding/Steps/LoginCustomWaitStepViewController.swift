//
//  LoginCustomWaitStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import ResearchKit

class LoginCustomWaitStep: ORKStep {
    
    static let identifier = "LoginCustomWaitStep"
    
    override func stepViewControllerClass() -> AnyClass {
        return LoginCustomWaitStepViewController.self
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class LoginCustomWaitStepViewController: ORKStepViewController {
    
    var onLoginCallback: NSObjectProtocol?
    
    override init(step: ORKStep?) {
        super.init(step: step)
    }
    
    override init(step: ORKStep, result: ORKResult) {
        super.init(step: step, result: result)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadCustomBackButton()
        
        onLoginCallback = NotificationCenter.default.addObserver(forName: NSNotification.Name(Constants.notificationUserLogin), object: nil, queue: OperationQueue.main) { (notification) in
            self.continueIfLoggedIn()
            print("Continuing; received callback.")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CKStudyUser.shared.isLoggedIn { // we are already logged in
            self.continueIfLoggedIn()
            print("Continuing; already logged in.")
        }
    }
    
    func continueIfLoggedIn() {
        CKStudyUser.shared.save()
        
        self.removeLoginObserver()
        self.goForward()
    }
    
    func removeLoginObserver() {
        if let onLoginCallback = self.onLoginCallback {
            NotificationCenter.default.removeObserver(onLoginCallback)
        }
    }
    
    func loadCustomBackButton() {
        let backItem = UIBarButtonItem()
        backItem.title = "wrong email?"
        
        self.navigationItem.backBarButtonItem = backItem 
    }
    
    @IBAction func wrongEmail(_ sender: UIButton) {
        goBackward()
    }
    
    @IBAction func openEmailPressed(_ sender: UIButton) {
        if let mailURL = URL(string: "message://"), UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
        }
    }
    
}
