//
//  TestViewController.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 7/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import CareKitUI
import CareKitStore

class TestViewController: OCKSimpleTaskViewController, ORKTaskViewControllerDelegate{
    
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
        let answer = Int(truncating: feedbackResult.scaleAnswer!)

        // 4b. Save the result into CareKit's store
        controller.appendOutcomeValue(value: answer, at: IndexPath(item: 0, section: 0), completion: nil)
        
        // 5. Upload results to GCP, using the CKTaskViewControllerDelegate class.
        let gcpDelegate = CKUploadToGCPTaskViewControllerDelegate()
        gcpDelegate.taskViewController(taskViewController, didFinishWith: reason, error: error)
    }
}

class TestItemViewSynchronizer: OCKSimpleTaskViewSynchronizer {
    
    override func makeView() -> OCKSimpleTaskView {
        let instructionsView = super.makeView()
//        instructionsView.headerView.detailLabel.text = "this is detail"
//        instructionsView.headerView.titleLabel.text = "this is title"
        return instructionsView
    }
    
    override func updateView(_ view: OCKSimpleTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
        super.updateView(view, context: context)
//        view.headerView.detailLabel.text = "This is detail"
//        view.headerView.titleLabel.text = "this is title"
    }
}
