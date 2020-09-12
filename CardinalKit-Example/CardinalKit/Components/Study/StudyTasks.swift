//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
*/
struct StudyTasks {
    
    /**
     Active tasks created with short-hand constructors from `ORKOrderedTask`
    */
    static let trailMakingA: ORKOrderedTask = {
        let intendedUseDescription = "Trail Making A"
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making A", intendedUseDescription: intendedUseDescription, trailmakingInstruction: "....", trailType: .A, options: ORKPredefinedTaskOption())
    }()
    
    static let trailMakingB: ORKOrderedTask = {
        let intendedUseDescription = "Trail Making B"
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making B", intendedUseDescription: intendedUseDescription, trailmakingInstruction: "blah blah", trailType: .B, options: ORKPredefinedTaskOption())
    }()
    
    static let spatial: ORKOrderedTask = {
        let intendedUseDescription = "Spatial Memory Test"
        
        return ORKOrderedTask.spatialSpanMemoryTask(withIdentifier: "Spatial Memory", intendedUseDescription: intendedUseDescription, initialSpan: 4, minimumSpan: 2, maximumSpan: 8, playSpeed: 20, maximumTests: 3, maximumConsecutiveFailures: 5, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: ORKPredefinedTaskOption())
    }()
    
   static let speechRecognition: ORKOrderedTask = {
       let intendedUseDescription = "Speech Recognition"

    return ORKOrderedTask.speechRecognitionTask(withIdentifier: "Speech Recognition", intendedUseDescription: intendedUseDescription, speechRecognizerLocale: ORKSpeechRecognizerLocale(rawValue: "en-US"), speechRecognitionImage: nil, speechRecognitionText: "Today is Monday and the air is smokey and grey.", shouldHideTranscript: true, allowsEdittingTranscript: false, options: ORKPredefinedTaskOption())
   }()

   static let amslerGrid: ORKOrderedTask = {
       let intendedUseDescription = "Amsler Grid"

       return ORKOrderedTask.amslerGridTask(withIdentifier: "Amsler Grid", intendedUseDescription: intendedUseDescription, options: ORKPredefinedTaskOption())
   }()
    
    
    /**
        Coffee Task Example for 9/2 Workshop
     */
    static let coffeeTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Patient Questionnaire"
        instructionStep.text = "This information will help your doctors keep track of how you feel and how well you are able to do your usual activities. If you are unsure about how to answer a question, please give the best answer you can and make a written comment beside your answer."
        
        steps += [instructionStep]
        
        // Coffee Step
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 0, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "A Lot 😬", minimumValueDescription: "None 😴")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "HealthScaleQuestionStep", title: "Coffee Intake", question: "How many cups of coffee did you have today?", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you for tracking your coffee."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-Coffee", steps: steps)
        
    }()
    
    /**
     Sample task created step-by-step!
    */
    static let sf12Task: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Patient Questionnaire"
        instructionStep.text = "This information will help your doctors keep track of how you feel and how well you are able to do your usual activities. If you are unsure about how to answer a question, please give the best answer you can and make a written comment beside your answer."
        
        steps += [instructionStep]
        
        //In general, would you say your health is:
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Excellent", minimumValueDescription: "Poor")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "HealthScaleQuestionStep", title: "Question #1", question: "In general, would you say your health is:", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        let textChoices = [
            ORKTextChoice(text: "Yes, Limited A lot", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, Limited A Little", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol)
        ]
        let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        let textStep = ORKQuestionStep(identifier: "TextStep", title: "Daily Activities", question: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answer: textChoiceAnswerFormat)
        
        steps += [textStep]
        
        
        let formItem = ORKFormItem(identifier: "FormItem1", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: textChoiceAnswerFormat)
        let formItem2 = ORKFormItem(identifier: "FormItem2", text: "Climbing SEVERAL flights of stairs:", answerFormat: textChoiceAnswerFormat)
        let formStep = ORKFormStep(identifier: "FormStep", title: "Daily Activities", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
        formStep.formItems = [formItem, formItem2]
        
        steps += [formStep]
        
        let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
        let booleanQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: "In the past four weeks, did you feel limited in the kind of work that you can accomplish?", answer: booleanAnswer)
        
        steps += [booleanQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-SF12", steps: steps)
    }()
}
