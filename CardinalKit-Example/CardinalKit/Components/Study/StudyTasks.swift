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
    static let survey: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "survey")
        instructionStep.title = "Patient Questionnaire"
        instructionStep.text = "This information will help your doctors understand some background about your health."
        
        steps += [instructionStep]
        
        // Age Step
        let ageAnswerFormat = ORKAnswerFormat.decimalAnswerFormat(withUnit: "Age in years?")
        let ageQuestionStep = ORKQuestionStep(identifier: "ageQuestionStep", title: "Age", question: "How old are you?", answer: ageAnswerFormat)
        steps += [ageQuestionStep]
        
        //Sex
        let sexAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "Female", value: "Female" as NSString), ORKTextChoice(text: "Male", value: "Male" as NSString)])
        let sexQuestionStep = ORKQuestionStep(identifier: "sexQuestionStep", title: "Sex", question: "Please select your gender", answer: sexAnswerFormat)
        steps += [sexQuestionStep]
        
        //Ethnicity
        let ethnicityAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "American Indian or Alaska Native", value: "American Indian or Alaska Native" as NSString), ORKTextChoice(text: "Asian", value: "Asian" as NSString), ORKTextChoice(text: "Hispanic or Latino", value: "Hispanic or Latino" as NSString), ORKTextChoice(text: "Native Hawaiian or Other Pacific Islander", value: "Native Hawaiian or Other Pacific Islander" as NSString), ORKTextChoice(text: "White", value: "White" as NSString)])
        let ethnicityQuestionStep = ORKQuestionStep(identifier: "ethnicityQuestionStep", title: "Ethnicity", question: "Please enter your Ethnicity", answer: ethnicityAnswerFormat)
        steps += [ethnicityQuestionStep]
        
        //Education
        let educationAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "No Schooling", value: "No Schooling" as NSString), ORKTextChoice(text: "High School Diploma", value: "High School Diploma" as NSString), ORKTextChoice(text: "Bachelor's Degree", value: "Bachelor's Degree" as NSString), ORKTextChoice(text: "Master's Degree", value: "Master's Degree" as NSString), ORKTextChoice(text: "Doctorate", value: "Doctorate" as NSString)])
        let educationQuestionStep = ORKQuestionStep(identifier: "educationQuestionStep", title: "Education Level", question: "Please select Highest Degree Earned", answer: educationAnswerFormat)
        steps += [educationQuestionStep]
        
        //Stroke History?
        let strokeAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let strokeQuestionStep = ORKQuestionStep(identifier: "strokeQuestionStep", title: "Stroke Question", question: "Have you had a stroke before (Yes or No)", answer: strokeAnswerFormat)
        steps += [strokeQuestionStep]
        
        //Parkinson's History?
        //let parkinsonsAnswerFormat = ORKAnswerFormat.textAnswerFormat()
        let parkinsonsAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let parkinsonsQuestionStep = ORKQuestionStep(identifier: "parkinsonsQuestionStep", title: "Parkinsons Question", question: "Have you ever been diagnosed with Parkinson's?", answer: parkinsonsAnswerFormat)
        steps += [parkinsonsQuestionStep]
        
        //Known Relatives with Parkinsons (none, 1st, 2nd)
        let relparkinsonsAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "None", value: "None" as NSString), ORKTextChoice(text: "1st Degree Relative", value: "1st Degree Relative" as NSString), ORKTextChoice(text: "2nd Degree Relative", value: "2nd Degree Relative" as NSString)])
        let relparkinsonsQuestionStep = ORKQuestionStep(identifier: "relparkinsonsQuestionStep", title: "Parkinson's in Relatives", question: "Have any of your relatives been diagnosed with Parkinson's?", answer: relparkinsonsAnswerFormat)
        steps += [relparkinsonsQuestionStep]
        
        //Known Relatives with Dementia (none, 1st, 2nd)
        let reldementiaAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "None", value: "None" as NSString), ORKTextChoice(text: "1st Degree Relative", value: "1st Degree Relative" as NSString), ORKTextChoice(text: "2nd Degree Relative", value: "2nd Degree Relative" as NSString)])
        let reldementiaQuestionStep = ORKQuestionStep(identifier: "reldementiaQuestionStep", title: "Dementia in Relatives", question: "Have any of your relatives been diagnosed with Dementia?", answer: reldementiaAnswerFormat)
        steps += [reldementiaQuestionStep]
        
        //Handedness
        let handedAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "Right", value: "Right" as NSString), ORKTextChoice(text: "Left", value: "Left" as NSString)])
        let handedQuestionStep = ORKQuestionStep(identifier: "handedQuestionStep", title: "Right or Left Handed?", question: "Which is your dominant hand?", answer: handedAnswerFormat)
        steps += [handedQuestionStep]
        
        //Diagnosis of Cognitive impairment
        let diagnosisAnswerFormat = ORKAnswerFormat.textAnswerFormat()
        let diagnosisQuestionStep = ORKQuestionStep(identifier: "diagnosisQuestionStep", title: "Previous Cognitive Impariment", question: "Have you ever been diagnosed with a Cognitive Impairment? If yes please specify.", answer: diagnosisAnswerFormat)
        steps += [diagnosisQuestionStep]
        
        return ORKOrderedTask(identifier: "Survey", steps: steps)
        
    }()
    
    static let trailMakingA: ORKOrderedTask = {
        let intendedUseDescription = "Trail Making A"
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making A", intendedUseDescription: intendedUseDescription, trailmakingInstruction: "", trailType: .A, options: ORKPredefinedTaskOption())
    }()
    
    static let trailMakingB: ORKOrderedTask = {
        let intendedUseDescription = "Trail Making B"
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making B", intendedUseDescription: intendedUseDescription, trailmakingInstruction: "", trailType: .B, options: ORKPredefinedTaskOption())
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
