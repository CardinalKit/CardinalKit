//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

extension ORKStep {
    enum Identifier: String {
        case nameQuestionStep
        case dobQuestionStep
        case sexQuestionStep
        case locationQuestionStep
        case ethnicityQuestionStep
        case educationQuestionStep
        case handedQuestionStep
    }
}

/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
 */
struct StudyTasks {
    static let basicInfoSurvey: ORKOrderedTask = {
        var steps = [ORKStep]()

        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "survey")
        instructionStep.title = "Basic Info Form"
        instructionStep.text = "We'll update your basic informations with this questionnaire."
        steps += [instructionStep]

        // Name
        let nameQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.nameQuestionStep.rawValue,
            title: "Name",
            question: "What is your full name?",
            answer: .textAnswerFormat()
        )
        steps += [nameQuestionStep]

        // Date of Birth Step
        let dobQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.dobQuestionStep.rawValue,
            title: "Age",
            question: "What's your date of birth?",
            answer: ORKHealthKitCharacteristicTypeAnswerFormat(
                characteristicType: .characteristicType(forIdentifier: .dateOfBirth)!))
        steps += [dobQuestionStep]

        // Sex
        let sexQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.sexQuestionStep.rawValue,
            title: "Sex",
            question: "What's your sex assigned at birth",
            answer: ORKHealthKitCharacteristicTypeAnswerFormat(
                characteristicType: .characteristicType(forIdentifier: .biologicalSex)!))
        steps += [sexQuestionStep]

        // Handedness
        let handedAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [
            ORKTextChoice(text: "Right", value: "Right" as NSString),
            ORKTextChoice(text: "Left", value: "Left" as NSString),
            ORKTextChoice(text: "Ambidextrous", value: "Ambidextrous" as NSString)
        ])
        let handedQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.handedQuestionStep.rawValue,
            title: "Right or Left Handed?",
            question: "Which is your dominant hand?",
            answer: handedAnswerFormat)
        steps += [handedQuestionStep]

        // Ethnicity
        let ethnicityAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [
            ORKTextChoice(text: "American Indian or Alaska Native", value: "American Indian or Alaska Native" as NSString),
            ORKTextChoice(text: "Asian", value: "Asian" as NSString),
            ORKTextChoice(text: "Hispanic or Latino", value: "Hispanic or Latino" as NSString),
            ORKTextChoice(text: "Native Hawaiian or Other Pacific Islander", value: "Native Hawaiian or Other Pacific Islander" as NSString),
            ORKTextChoice(text: "White", value: "White" as NSString)
        ])
        let ethnicityQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.ethnicityQuestionStep.rawValue,
            title: "Ethnicity", question: "Which ethnicity describes you?",
            answer: ethnicityAnswerFormat)
        steps += [ethnicityQuestionStep]

        // Education
        let educationAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: [
            ORKTextChoice(text: "No Schooling", value: "No Schooling" as NSString),
            ORKTextChoice(text: "High School Diploma", value: "High School Diploma" as NSString),
            ORKTextChoice(text: "Bachelor's Degree", value: "Bachelor's Degree" as NSString),
            ORKTextChoice(text: "Master's Degree", value: "Master's Degree" as NSString),
            ORKTextChoice(text: "Doctorate", value: "Doctorate" as NSString)
        ])
        let educationQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.educationQuestionStep.rawValue,
            title: "Education Level",
            question: "What is the highest degree you earned?",
            answer: educationAnswerFormat
        )
        steps += [educationQuestionStep]

        // Location (Zip code)
        let locationQuestionStep = ORKQuestionStep(
            identifier: ORKStep.Identifier.locationQuestionStep.rawValue,
            title: "Location",
            question: "What's your current location?",
            answer: .locationAnswerFormat())
        steps += [locationQuestionStep]

        return ORKOrderedTask(identifier: "BasicInfo", steps: steps)
    }()
    
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

        // Stroke History?
        let strokeAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
        let strokeQuestionStep = ORKQuestionStep(identifier: "strokeQuestionStep", title: "Stroke Question", question: "Have you had a stroke before?", answer: strokeAnswerFormat)
        steps += [strokeQuestionStep]
        
        // Parkinson's History?
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
        
        //Diagnosis of Cognitive impairment
        let diagnosisAnswerFormat = ORKAnswerFormat.textAnswerFormat()
        let diagnosisQuestionStep = ORKQuestionStep(identifier: "diagnosisQuestionStep", title: "Previous Cognitive Impariment", question: "Have you ever been diagnosed with a Cognitive Impairment? If yes, please specify.", answer: diagnosisAnswerFormat)
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
