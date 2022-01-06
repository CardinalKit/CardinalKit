//
//  SurveyItemViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/23/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import CareKitUI
import CareKitStore

// 1. Subclass a task view controller to customize the control flow and present a ResearchKit survey!
class SurveyItemViewController: OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {

    // 2. This method is called when the use taps the button!
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {

        // 2a. If the task was marked incomplete, fall back on the super class's default behavior or deleting the outcome.
        if !isComplete {
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
            return
        }

        // 2b. If the user attempted to mark the task complete, display a ResearchKit survey.
        let answerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 5, step: 1, vertical: false, maximumValueDescription: "A LOT!", minimumValueDescription: "a little")
        let feedbackStep = ORKQuestionStep(identifier: "feedback", title: "Feedback", question: "How are you liking CardinalKit?", answer: answerFormat)
        let surveyTask = ORKOrderedTask(identifier: "feedback", steps: [feedbackStep])
        let surveyViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        surveyViewController.delegate = self

        // 3a. Present the survey to the user
        present(surveyViewController, animated: false, completion: nil)
    }

    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: false, completion: nil)
        guard reason == .completed else {
            taskView.completionButton.isSelected = false
            return
        }
        // 4a. Retrieve the result from the ResearchKit survey
        let survey = taskViewController.result.results!.first(where: { $0.identifier == "feedback" }) as! ORKStepResult
        let feedbackResult = survey.results!.first as! ORKScaleQuestionResult
        
        if let ScaleAnswer = feedbackResult.scaleAnswer{
            // 4b. Save the result into CareKit's store
            let answer = Int(truncating: ScaleAnswer)
            controller.appendOutcomeValue(value: answer, at: IndexPath(item: 0, section: 0), completion: nil)
            // 5. Upload results to GCP, using the CKTaskViewControllerDelegate class.
            let gcpDelegate = CKUploadToGCPTaskViewControllerDelegate()
            gcpDelegate.taskViewController(taskViewController, didFinishWith: reason, error: error)
        }
        else{
            taskView.completionButton.isSelected = false
            let gcpDelegate = CKUploadToGCPTaskViewControllerDelegate()
            gcpDelegate.taskViewController(taskViewController, didFinishWith: .discarded, error: error)
        }
    }
}

class SurveyItemViewSynchronizer: OCKInstructionsTaskViewSynchronizer {

    // Customize the initial state of the view
    override func makeView() -> OCKInstructionsTaskView {
        let instructionsView = super.makeView()
        instructionsView.completionButton.label.text = "Start"
        return instructionsView
    }
    
    override func updateView(_ view: OCKInstructionsTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
        super.updateView(view, context: context)

        // Check if an answer exists or not and set the detail label accordingly
        let element: [OCKAnyEvent]? = context.viewModel.first
        let firstEvent = element?.first
        
        if let answer = firstEvent?.outcome?.values.first?.integerValue {
            view.headerView.detailLabel.text = "CardinalKit Rating: \(answer)"
        } else {
            view.headerView.detailLabel.text = "How are you liking CardinalKit?"
        }
    }
}
