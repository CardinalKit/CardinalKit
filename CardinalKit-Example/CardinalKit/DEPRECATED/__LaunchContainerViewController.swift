//
//  LaunchContainerViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import Firebase
import CardinalKit

class LaunchContainerViewController: UIViewController {
    
    var contentHidden = false {
        didSet {
            guard contentHidden != oldValue && isViewLoaded else { return }
            children.first?.view.isHidden = contentHidden
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            toStudy()
        }
        else {
            toOnboarding()
        }
    }
    
    @IBAction func unwindToStudy(_ unwindSegue: UIStoryboardSegue) {
        toStudy()
    }
    
    @IBAction func unwindToWithdrawal(_ unwindSegue: UIStoryboardSegue) {
        toWithdrawal()
    }
    
    // MARK: Transitions

    func toStudy() {
        performSegue(withIdentifier: "toStudy", sender: self)
    }
    
    func toOnboarding() {
        performSegue(withIdentifier: "toOnboarding", sender: self)
    }
    
    func toWithdrawal() {
        let viewController = WithdrawViewController()
        viewController.delegate = self
        
        present(viewController, animated: true, completion: nil)
    }

}

extension LaunchContainerViewController: ORKTaskViewControllerDelegate {
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Check if the user has finished the `WithdrawViewController`.
        if taskViewController is WithdrawViewController {
            /*
             If the user has completed the withdrawl steps, remove them from
             the study and transition to the onboarding view.
             */
            if reason == .completed {
                do {
                    try Auth.auth().signOut()
                    
                    if (ORKPasscodeViewController.isPasscodeStoredInKeychain()) {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }
                    
                    toOnboarding()
                } catch {
                    print(error.localizedDescription)
                    Alerts.showInfo(title: "Error", message: error.localizedDescription)
                }
            }
            
            // Dismiss the `WithdrawViewController`.
            dismiss(animated: true, completion: nil)
        }
    }
}
