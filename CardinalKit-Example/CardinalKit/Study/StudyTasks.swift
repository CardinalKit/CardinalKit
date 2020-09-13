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
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making A", intendedUseDescription: intendedUseDescription, trailmakingInstruction: nil, trailType: .A, options: [])
    }()
    
    static let trailMakingB: ORKOrderedTask = {
        let intendedUseDescription = "Trail Making B"
        
        return ORKOrderedTask.trailmakingTask(withIdentifier: "Trail making B", intendedUseDescription: intendedUseDescription, trailmakingInstruction: nil, trailType: .B, options: [])
    }()
    
    static let spatial: ORKOrderedTask = {
        let intendedUseDescription = "Spatial Memory Test"
        
        return ORKOrderedTask.spatialSpanMemoryTask(withIdentifier: "Spatial Memory", intendedUseDescription: intendedUseDescription, initialSpan: 4, minimumSpan: 2, maximumSpan: 8, playSpeed: 20, maximumTests: 3, maximumConsecutiveFailures: 5, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: [])
    }()

    static let speechRecognitionText = "Today is Monday and the air is smokey and grey."
    static let speechRecognition: ORKOrderedTask = {
        let intendedUseDescription = "Speech Recognition"

        return ORKOrderedTask.speechRecognitionTask(withIdentifier: "Speech Recognition", intendedUseDescription: intendedUseDescription, speechRecognizerLocale: ORKSpeechRecognizerLocale(rawValue: "en-US"), speechRecognitionImage: nil, speechRecognitionText: speechRecognitionText, shouldHideTranscript: true, allowsEdittingTranscript: false, options: [])
    }()

    static let amslerGrid: ORKOrderedTask = {
        let intendedUseDescription = "Amsler Grid"

        return ORKOrderedTask.amslerGridTask(withIdentifier: "Amsler Grid", intendedUseDescription: intendedUseDescription, options: [])
    }()
}
