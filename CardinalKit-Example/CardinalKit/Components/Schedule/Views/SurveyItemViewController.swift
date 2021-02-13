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
import FirebaseAuth
import FirebaseFirestore

// 1. Subclass a task view controller to customize the control flow and present a ResearchKit survey!
class SurveyItemViewController: OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {

    // 2. This method is called when the use taps the button!
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {

        // 2a. If the task was marked incomplete, fall back on the super class's default behavior or deleting the outcome.
        if !isComplete {
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
            return
        }

        var steps = [ORKStep]()
                
        let answerFormatEmail = ORKAnswerFormat.emailAnswerFormat()
                let stringAnswerFormat = ORKTextAnswerFormat()
                // Question 1 is asking about how one's feeling today
                let moodTypes = [
                  ORKTextChoice(text: "Great", value: 0 as NSNumber),
                  ORKTextChoice(text: "Good", value: 1 as NSNumber),
                  ORKTextChoice(text: "OK", value: 2 as NSNumber),
                  ORKTextChoice(text: "Not so great", value: 3 as NSNumber)
                ]
                let moodTypeAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: moodTypes)
                let moodTypeQuestionStep = ORKQuestionStep(identifier: "moodTypeQuestionStep", title: "Mood Type", question: "How are you feeling today?", answer: moodTypeAnswerFormat)
                steps += [moodTypeQuestionStep]
                // Question 2 is asking about whether the user followed the routine
                let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes!", noString: "No")
                let booleanStep = ORKQuestionStep(identifier: "Routine-Boolean", title: "Routine", question: "Did you follow the skincare routing that our AI sugegsted for you?", answer: booleanAnswer)
                booleanStep.isOptional = true
                steps += [booleanStep]
                // if not then we ll ask the customer to do so so we can best help them cure their acne
                let textAnswerFormat = ORKTextAnswerFormat(maximumLength: 200)
                textAnswerFormat.multipleLines = true
                let routineQuestionStep = ORKQuestionStep(identifier: "RoutineQuestionStep", title: "Routine", question: "Please explain why you did not follow your skincare routine, we can build a routine that better fits your needs.", answer: textAnswerFormat)
                // Question 3 is aking about whether they have seen any improvements
                let skinCondition = [
                  ORKTextChoice(text: "Breakouts", value: 0 as NSNumber),
                  ORKTextChoice(text: "Clogged pores", value: 1 as NSNumber),
                  ORKTextChoice(text: "Acne scars", value: 2 as NSNumber),
                  ORKTextChoice(text: "Dark spots", value: 3 as NSNumber),
                  ORKTextChoice(text: "Wrinkles", value: 4 as NSNumber),
                  ORKTextChoice(text: "Fine lines", value: 5 as NSNumber),
                ]
                let skinImprovementAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: skinCondition)
                let skinImprovementQuestionStep = ORKQuestionStep(identifier: "SkinImprovementQuestionStep", title: "Skin Evolution", question: "Did you notice improvements for any of the following skin conditions?", answer: skinImprovementAnswerFormat)
                steps += [skinImprovementQuestionStep]
                let skinWorseningQuestionStep = ORKQuestionStep(identifier: "SkinWorseningQuestionStep", title: "Skin Evolution", question: "Did any of the below symptoms worsen since you started your routine?", answer: skinImprovementAnswerFormat)
                steps += [skinWorseningQuestionStep]
                // Question 5 is asking to upload a dail photo
                let instructionStep = ORKInstructionStep(identifier: "imageCaptureInstructionStep")
                instructionStep.title = NSLocalizedString("Time to take a selfie so we can keep track of your skin progression", comment: "")
                instructionStep.text = "Please take a photo of yourself, position your face as indicated and make sure you have good lighting."
                let handSolidImage = UIImage(systemName: "person.fill")!
                instructionStep.image = handSolidImage.withRenderingMode(.alwaysTemplate)
                instructionStep.isOptional = false
                let imageCaptureStep = ORKImageCaptureStep(identifier: "imageCaptureStep")
                imageCaptureStep.title = NSLocalizedString("Image Capture", comment: "")
                imageCaptureStep.isOptional = true
                imageCaptureStep.accessibilityInstructions = NSLocalizedString("Your instructions for capturing the image", comment: "")
                imageCaptureStep.accessibilityHint = NSLocalizedString("Captures the image visible in the preview", comment: "")
                imageCaptureStep.templateImage = UIImage(systemName: "person.fill")!
                imageCaptureStep.templateImageInsets = UIEdgeInsets(top: 0.05, left: 0.05, bottom: 0.05, right: 0.05)
                steps += [instructionStep, imageCaptureStep]
                // Summary step
//                steps += [routineQuestionStep]
                let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
                summaryStep.title = "All done!"
                summaryStep.text = "Our AI will review this information and update your routine if needed. See you soon for your next skin check-up!"
                steps += [summaryStep]
                // create navigable rule for allergy question
//                let resultBooleanSelector = ORKResultSelector(resultIdentifier: booleanStep.identifier)
//                let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultBooleanSelector, expectedAnswer: false)
//                let navigableRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(resultPredicate: predicate, destinationStepIdentifier: routineQuestionStep.identifier)])
//                // create task grouping all steps
                let task =  ORKNavigableOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
//                task.setNavigationRule(navigableRule, forTriggerStepIdentifier: booleanStep.identifier)
        
        
        let surveyViewController = ORKTaskViewController(task: task, taskRun: nil)
        surveyViewController.delegate = self

        // 3a. Present the survey to the user
        present(surveyViewController, animated: true, completion: nil)
    }

    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
        guard reason == .completed else {
            taskView.completionButton.isSelected = false
            return
        }

        // 4a. Retrieve the result from the ResearchKit survey
//        let survey = taskViewController.result.results!.first(where: { $0.identifier == "Allergies-Boolean" }) as! ORKStepResult
//        let feedbackResult = survey.results!.first as! ORKBooleanQuestionResult
//        let answer = Int(truncating: feedbackResult.booleanAnswer!)
//
//        // 4b. Save the result into CareKit's store
//        controller.appendOutcomeValue(value: answer, at: IndexPath(item: 0, section: 0), completion: nil)
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
            view.headerView.detailLabel.text = "Quick daily survey"
        }
    }
}

