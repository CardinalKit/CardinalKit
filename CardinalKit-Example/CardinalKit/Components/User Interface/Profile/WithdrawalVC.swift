//
//  WithdrawalVC.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import CardinalKit
import ResearchKit
import FirebaseAuth

struct WithdrawalVC: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    @EnvironmentObject var config: CKPropertyReader

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let instructionStep = ORKInstructionStep(identifier: "WithdrawlInstruction")
        instructionStep.title = config.read(query: "Withdrawal Instruction Title")
        instructionStep.text = config.read(query: "Withdrawal Instruction Text")

        let completionStep = ORKCompletionStep(identifier: "Withdraw")
        completionStep.title = config.read(query: "Withdraw Title")
        completionStep.text = config.read(query: "Withdraw Text")

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

                    if ORKPasscodeViewController.isPasscodeStoredInKeychain() {
                        ORKPasscodeViewController.removePasscodeFromKeychain()
                    }

                    taskViewController.dismiss(animated: true, completion: {
                        exit(EXIT_SUCCESS)
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

struct WithdrawalVC_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalVC()
    }
}
