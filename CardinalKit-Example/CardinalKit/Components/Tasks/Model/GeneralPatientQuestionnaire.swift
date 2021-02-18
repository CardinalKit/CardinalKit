//
//  StudyTasks.swift
//
//  Created for Biodesign's CS342
//  Copyright © 2019 Stanford University.
//  All rights reserved.
//

import ResearchKit

/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
*/
struct GeneralPatientQuestionnaire {
    
    /**
     Sample task template!
    */
    static let form: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        /*
            CS342 -- ASSIGNMENT 2
            Add steps to the array above to create a survey!
         */
        
        // Introduction
        let instructionStep = ORKInstructionStep(identifier: "Introstep")
        instructionStep.title = "SF-12 Patient Questionnaire"
        instructionStep.text = "Welcome"
        instructionStep.image = UIImage(named: "doctor")
        instructionStep.detailText = "This information will help your doctors keep track of how you feel and how well you are able to do your usual activities.  If you are unsure about how to answer a question, please give the best answer you can."
        steps.append(instructionStep)
        
        // Q1
        let firstStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Excellent", minimumValueDescription: "Poor")
        let firstStep = ORKQuestionStep(identifier: "SF-12-1", title: "Patient Questionnaire", question: "In general, how would you describe your health?", answer: firstStepAnswerFormat)
        steps.append(firstStep)
        
        // Q2
        let secondStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 1, defaultValue: 2, step: 1, vertical: false, maximumValueDescription: "Limited a lot", minimumValueDescription: "Not limited at all")
        let secondStep = ORKQuestionStep(identifier: "SF-12-2", title: "Activites", question: "To what extent does your health limit you in moderate activities, such as moving a table, pushing a vacuum cleaner, or playing golf?", answer: secondStepAnswerFormat)
        steps.append(secondStep)
        
        // Q3
        let thirdStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 1, defaultValue: 2, step: 1, vertical: false, maximumValueDescription: "Limited a lot", minimumValueDescription: "Not limited at all")
        let thirdStep = ORKQuestionStep(identifier: "SF-12-3", title: "Activites", question: "To what extent does your health limit you walking up several flights of stairs consecutively?", answer: thirdStepAnswerFormat)
        steps.append(thirdStep)
        
        // Q4
        let fourthStepAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let fourthStep = ORKQuestionStep(identifier: "SF-12-4", title: "Activities", question: "During the past four weeks, have you accomplished less than you would like due to your physical health?", answer: fourthStepAnswerFormat)
        steps.append(fourthStep)
        
        // Q5
        let fifthStepAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let fifthStep = ORKQuestionStep(identifier: "SF-12-5", title: "Activities", question: "During the past four weeks, have you been limited in the kind of work or activities you can undertake by your physical health?", answer: fifthStepAnswerFormat)
        steps.append(fifthStep)
        
        // Q6
        let sixthStepAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let sixthStep = ORKQuestionStep(identifier: "SF-12-6", title: "Activities", question: "During the past four weeks, have you accomplished less than you would like due to emotional problems?", answer: sixthStepAnswerFormat)
        steps.append(sixthStep)
        
        // Q7
        let seventhStepAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let seventhStep = ORKQuestionStep(identifier: "SF-12-7", title: "Activities", question: "During the past four weeks, did you perform work or activities less carefully than usual due to emotional problems?", answer: seventhStepAnswerFormat)
        steps.append(seventhStep)
        
        // Q8
        let eighthStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Extremely", minimumValueDescription: "Not at all")
        let eighthStep = ORKQuestionStep(identifier: "SF-12-8", title: "Pain", question: "During the last four weeks, how much did pain interfere with your normal work (including both housework and work outside the home)?", answer: eighthStepAnswerFormat)
        steps.append(eighthStep)
        
        // Q9
        let ninthStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 6, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "All of the time", minimumValueDescription: "None of the time")
        let ninthStep = ORKQuestionStep(identifier: "SF-12-9", title: "Emotions", question: "During the last four weeks, how often have you felt calm and peaceful?", answer: ninthStepAnswerFormat)
        steps.append(ninthStep)
        
        // Q10
        let tenthStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 6, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "All of the time", minimumValueDescription: "None of the time")
        let tenthStep = ORKQuestionStep(identifier: "SF-12-10", title: "Emotions", question: "During the last four weeks, how often have you had a lot of energy?", answer: tenthStepAnswerFormat)
        steps.append(tenthStep)
        
        // Q11
        let eleventhStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 6, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "All of the time", minimumValueDescription: "None of the time")
        let eleventhStep = ORKQuestionStep(identifier: "SF-12-11", title: "Emotions", question: "During the last four weeks, how often have you felt downhearted and blue?", answer: eleventhStepAnswerFormat)
        steps.append(eleventhStep)
        
        // Q12
        let twelfthStepAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 6, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "All of the time", minimumValueDescription: "None of the time")
        let twelfthStep = ORKQuestionStep(identifier: "SF-12-12", title: "Emotions", question: "During the last four weeks, how often has your physical health or emotional problems interfered with your social activities (like visiting with friends, relatives, etc.)?", answer: twelfthStepAnswerFormat)
        steps.append(twelfthStep)
        
        let summaryStep = ORKInstructionStep(identifier: "SummaryStep")
        summaryStep.title = "SF-12 Complete"
        summaryStep.text = "Thank you for completing the survey."
        summaryStep.image = UIImage(named: "Portrait")
        steps.append(summaryStep)
        
        return ORKOrderedTask(identifier: "GeneralPatientQuestionnaire", steps: steps)
    }()
}
