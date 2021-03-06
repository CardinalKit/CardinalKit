//
//  SF12ViewController.swift
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
class SF12ViewController: OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {

    // 2. This method is called when the use taps the button!
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {

        // 2a. If the task was marked incomplete, fall back on the super class's default behavior or deleting the outcome.
        if !isComplete {
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
            return
        }
        
        // sf12
        var steps = [ORKStep]()

        // Question 1
        let q1textChoiceOneText = NSLocalizedString("Excellent (1)", comment: "")
        let q1textChoiceTwoText = NSLocalizedString("Very Good (2)", comment: "")
        let q1textChoiceThreeText = NSLocalizedString("Good (3)", comment: "")
        let q1textChoiceFourText = NSLocalizedString("Fair (4)", comment: "")
        let q1textChoiceFiveText = NSLocalizedString("Poor (5)", comment: "")
        
        let q1textChoices = [
            ORKTextChoice(text: q1textChoiceOneText, value: "Excellent (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceTwoText, value: "Very Good (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceThreeText, value: "Good (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFourText, value: "Fair (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFiveText, value: "Poor (5)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q1AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q1textChoices)
        
        let q1QuestionStep = ORKQuestionStep(identifier: "Q1", title: "Question 1", question: "In general, would you say your health is:", answer: q1AnswerFormat)
        
        q1QuestionStep.isOptional = false
        steps += [q1QuestionStep]
        
        // Question 2 and 3
        let q2q3textChoiceOneText = NSLocalizedString("Yes, Limited A Lot (1)", comment: "")
        let q2q3textChoiceTwoText = NSLocalizedString("Yes, Limited A Little (2)", comment: "")
        let q2q3textChoiceThreeText = NSLocalizedString("No, Not Limited At All (3)", comment: "")
        
        let q2q3textChoices = [
            ORKTextChoice(text: q2q3textChoiceOneText, value: "Yes, Limited A Lot (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q2q3textChoiceTwoText, value: "Yes, Limited A Little (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q2q3textChoiceThreeText, value: "No, Not Limited At All (3)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q2q3AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q2q3textChoices)
        
        let q2FormItem = ORKFormItem(identifier: "Q2", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: q2q3AnswerFormat)
        q2FormItem.isOptional = false
        
        let q3FormItem = ORKFormItem(identifier: "Q3", text: "Climbing SEVERAL flights of stairs:", answerFormat: q2q3AnswerFormat)
        q3FormItem.isOptional = false
        

        let q2q3FormStep = ORKFormStep(identifier: "q2q3", title: "Questions 2 and 3", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
        q2q3FormStep.formItems = [q2FormItem, q3FormItem]
        q2q3FormStep.isOptional = false
        steps += [q2q3FormStep]
        
        // Question 4 and 5
        let q4q5textChoiceOneText = NSLocalizedString("Yes (1)", comment: "")
        let q4q5textChoiceTwoText = NSLocalizedString("No (2)", comment: "")
        
        let q4q5textChoices = [
            ORKTextChoice(text: q4q5textChoiceOneText, value: "Yes (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q4q5textChoiceTwoText, value: "No (2)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q4q5AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q4q5textChoices)
        
        let q4FormItem = ORKFormItem(identifier: "Q4", text: "ACCOMPLISHED LESS than you would like:", answerFormat: q4q5AnswerFormat)
        q4FormItem.isOptional = false
        
        let q5FormItem = ORKFormItem(identifier: "Q5", text: "Were limited in the KIND of work or other activities:", answerFormat: q4q5AnswerFormat)
        q5FormItem.isOptional = false
        

        let q4q5FormStep = ORKFormStep(identifier: "q4q5", title: "Questions 4 and 5", text: "During the PAST 4 WEEKS have you had any of the following problems with your work or other regular activities AS A RESULT OF YOUR PHYSICAL HEALTH?")
        q4q5FormStep.formItems = [q4FormItem, q5FormItem]
        q4q5FormStep.isOptional = false
        steps += [q4q5FormStep]
        
        // Question 6 and 7
        let q6q7textChoiceOneText = NSLocalizedString("Yes (1)", comment: "")
        let q6q7textChoiceTwoText = NSLocalizedString("No (2)", comment: "")
        
        let q6q7textChoices = [
            ORKTextChoice(text: q6q7textChoiceOneText, value: "Yes (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q6q7textChoiceTwoText, value: "No (2)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q6q7AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q6q7textChoices)
        
        let q6FormItem = ORKFormItem(identifier: "Q6", text: "ACCOMPLISHED LESS than you would like:", answerFormat: q6q7AnswerFormat)
        q6FormItem.isOptional = false
        
        let q7FormItem = ORKFormItem(identifier: "Q7", text: "Didn’t do work or other activities as CAREFULLY as usual:", answerFormat: q6q7AnswerFormat)
        q7FormItem.isOptional = false
        

        let q6q7FormStep = ORKFormStep(identifier: "q6q7", title: "Questions 6 and 7", text: "During the PAST 4 WEEKS, were you limited in the kind of work you do or other regular activities AS A RESULT OF ANY EMOTIONAL PROBLEMS (such as feeling depressed or anxious)?")
        q6q7FormStep.formItems = [q6FormItem, q7FormItem]
        q6q7FormStep.isOptional = false
        steps += [q6q7FormStep]
        
        // Question 8
        let q8textChoices = [
            ORKTextChoice(text: q1textChoiceOneText, value: "Not At All (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceTwoText, value: "A Little Bit (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceThreeText, value: "Moderately (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFourText, value: "Quite A Bit (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFiveText, value: "Extremely (5)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q8AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q8textChoices)
        
        let q8QuestionStep = ORKQuestionStep(identifier: "Q8", title: "Question 8", question: "During the PAST 4 WEEKS, how much did PAIN interfere with your normal work (including both work outside the home and housework)?", answer: q8AnswerFormat)
        
        q8QuestionStep.isOptional = false
        steps += [q8QuestionStep]
        
        // Question 9, 10, and 11
        let q9q10q11textChoiceOneText = NSLocalizedString("All of the Time (1)", comment: "")
        let q9q10q11textChoiceTwoText = NSLocalizedString("Most of the Time (2)", comment: "")
        let q9q10q11textChoiceThreeText = NSLocalizedString("A Good Bit of the Time (3)", comment: "")
        let q9q10q11textChoiceFourText = NSLocalizedString("Some of the Time (4)", comment: "")
        let q9q10q11textChoiceFiveText = NSLocalizedString("A Little of the Time (5)", comment: "")
        let q9q10q11textChoiceSixText = NSLocalizedString("None of the Time (6)", comment: "")
        
        let q9q10q11textChoices = [
            ORKTextChoice(text: q9q10q11textChoiceOneText, value: "All of the Time (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceTwoText, value: "Most of the Time (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceThreeText, value: "A Good Bit of the Time (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFourText, value: "Some of the Time (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFiveText, value: "A Little of the Time (5)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceSixText, value: "None of the Time (6)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q9q10q11AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q9q10q11textChoices)
        
        let q9FormItem = ORKFormItem(identifier: "Q9", text: "Have you felt calm and peaceful?", answerFormat: q9q10q11AnswerFormat)
        q6FormItem.isOptional = false
        
        let q10FormItem = ORKFormItem(identifier: "Q10", text: "Did you have a lot of energy?", answerFormat: q9q10q11AnswerFormat)
        q10FormItem.isOptional = false
        
        let q11FormItem = ORKFormItem(identifier: "Q11", text: "Have you felt downhearted and blue?", answerFormat: q9q10q11AnswerFormat)
        q11FormItem.isOptional = false
        

        let q9q10q11FormStep = ORKFormStep(identifier: "q9q10q11", title: "Questions 9, 10, and 11", text: "The next three questions are about how you feel and how things have been DURING THE PAST 4 WEEKS. For each question, please give the one answer that comes closest to the way you have been feeling. How much of the time during the PAST 4 WEEKS –")
        q9q10q11FormStep.formItems = [q9FormItem, q10FormItem, q11FormItem]
        q9q10q11FormStep.isOptional = false
        steps += [q9q10q11FormStep]
        
        // Question 12
        let q12textChoices = [
            ORKTextChoice(text: q9q10q11textChoiceOneText, value: "All of the Time (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceTwoText, value: "Most of the Time (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceThreeText, value: "A Good Bit of the Time (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFourText, value: "Some of the Time (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFiveText, value: "A Little of the Time (5)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceSixText, value: "None of the Time (6)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q12AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q12textChoices)
        
        let q12QuestionStep = ORKQuestionStep(identifier: "Q12", title: "Question 12", question: "During the PAST 4 WEEKS, how much of the time has your PHYSICAL HEALTH OR EMOTIONAL PROBLEMS interfered with your social activities (like visiting with friends, relatives, etc.)? ", answer: q12AnswerFormat)
        
        q12QuestionStep.isOptional = false
        steps += [q12QuestionStep]
        
        // Summary step
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "All done!"
        steps += [summaryStep]
        
        let sf12task = ORKNavigableOrderedTask(identifier: "sf12", steps: steps)
        let sf12ViewController = ORKTaskViewController(task: sf12task, taskRun: nil)
        sf12ViewController.delegate = self

        // 3a. Present the survey to the user
        present(sf12ViewController, animated: true, completion: nil)
    }

    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
        guard reason == .completed else {
            taskView.completionButton.isSelected = false
            return
        }

//        // 4a. Retrieve the result from the ResearchKit survey
//        let survey = taskViewController.result.results!.first(where: { $0.identifier == "selfReportedHealth" }) as! ORKStepResult
//        let feedbackResult = survey.results!.first as! ORKScaleQuestionResult
//        let answer = Int(truncating: feedbackResult.scaleAnswer!)
//
//        // 4b. Save the result into CareKit's store
//        controller.appendOutcomeValue(value: answer, at: IndexPath(item: 0, section: 0), completion: nil)
    }
}

class SF12ItemViewSynchronizer: OCKInstructionsTaskViewSynchronizer {

    // Customize the initial state of the view
    override func makeView() -> OCKInstructionsTaskView {
        let instructionsView = super.makeView()
        instructionsView.completionButton.label.text = "Start"
        return instructionsView
    }
}
