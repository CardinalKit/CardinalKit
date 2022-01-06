//
//  WithdrawalViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI
import ResearchKit
import Firebase
import CardinalKit

struct WithdrawalViewController: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) {}
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

    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .completed:
                
                do {
                    try CKCareKitManager.shared.wipe()
                    try CKStudyUser.shared.signOut()
                    
                    if (ORKPasscodeViewController.isPasscodeStoredInKeychain()) {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(Constants.onboardingDidComplete), object: false)

                    UserDefaults.standard.set(nil, forKey: Constants.prefCareKitCoreDataInitDate)
                    UserDefaults.standard.set(nil, forKey: Constants.prefHealthRecordsLastUploaded)
                    UserDefaults.standard.set(false, forKey: Constants.onboardingDidComplete)
                } catch {
                    print(error.localizedDescription)
                    Alerts.showInfo(title: "Error", message: error.localizedDescription)
                }
                
                fallthrough
            default:
                
                // otherwise dismiss onboarding without proceeding.
                taskViewController.dismiss(animated: false, completion: nil)
                
            }
        }
    }
    
}
