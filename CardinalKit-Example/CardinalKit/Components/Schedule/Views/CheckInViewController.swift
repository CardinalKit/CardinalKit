//
//  CheckInViewController.swift
//  CardinalKit_Example
//
//  Created by Kabir Jolly on 3/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import CareKitUI
import CareKitStore

// 1. Subclass a task view controller to customize the control flow and present a ResearchKit survey!
class CheckInViewController: OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {

    // 2. This method is called when the use taps the button!
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {

        // 2a. If the task was marked incomplete, fall back on the super class's default behavior or deleting the outcome.
        if !isComplete {
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
            return
        }
        
        // Daily check-in
        // TODO: add blood pressure items here
        let numberAnswerFormat = ORKNumericAnswerFormat(style: .integer, unit: nil, minimum: 0 as NSNumber, maximum: 120 as NSNumber)
        let weightFormItem = ORKFormItem(identifier: "weight", text: "What is your weight (lbs)?", answerFormat: numberAnswerFormat, optional: false)
        weightFormItem.placeholder = NSLocalizedString("Enter your weight here", comment: "")
        
        let answerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 1, defaultValue: 5, step: 1, vertical: false, maximumValueDescription: "Great!", minimumValueDescription: "Unwell")
        let healthStep = ORKQuestionStep(identifier: "selfReportedHealth", title: "How are you feeling?", question: "Rate on a scale of 1-10", answer: answerFormat)
        
        let checkInFormStep = ORKFormStep(identifier: "CheckInForm", title: "Daily Check In", text: "")
        checkInFormStep.formItems = [weightFormItem]
        
        let checkInTask = ORKOrderedTask(identifier: "check-in", steps: [checkInFormStep, healthStep])
        let checkInViewController = ORKTaskViewController(task: checkInTask, taskRun: nil)
        checkInViewController.delegate = self

        // 3a. Present the survey to the user
        present(checkInViewController, animated: true, completion: nil)
    }

    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
        guard reason == .completed else {
            taskView.completionButton.isSelected = false
            return
        }

        // 4a. Retrieve the result from the ResearchKit survey
        let survey = taskViewController.result.results!.first(where: { $0.identifier == "selfReportedHealth" }) as! ORKStepResult
        let feedbackResult = survey.results!.first as! ORKScaleQuestionResult
        let answer = Int(truncating: feedbackResult.scaleAnswer!)

        // 4b. Save the result into CareKit's store
        controller.appendOutcomeValue(value: answer, at: IndexPath(item: 0, section: 0), completion: nil)
    }
}

class CheckInItemViewSynchronizer: OCKInstructionsTaskViewSynchronizer {

    // Customize the initial state of the view
    override func makeView() -> OCKInstructionsTaskView {
        let instructionsView = super.makeView()
        instructionsView.completionButton.label.text = "Start"
        return instructionsView
    }
}
