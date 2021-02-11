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
struct TaskSamples {
    
    /**
     Active tasks created with short-hand constructors from `ORKOrderedTask`
    */
    static let sampleTappingTask: ORKOrderedTask = {
        let intendedUseDescription = "Finger tapping is a universal way to communicate."
        
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: "TappingTask", intendedUseDescription: intendedUseDescription, duration: 10, handOptions: .both, options: ORKPredefinedTaskOption())
    }()
    
    static let sampleWalkingTask: ORKOrderedTask = {
        let intendedUseDescription = "Tests ability to walk"
        
        return ORKOrderedTask.shortWalk(withIdentifier: "ShortWalkTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 20, restDuration: 30, options: ORKPredefinedTaskOption())
    }()
    
    /**
        Coffee Task Example for 9/2 Workshop
     */
    static let sampleCoffeeTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Coffee Step
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 0, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "A Lot 😬", minimumValueDescription: "None 😴")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "CoffeeScaleQuestionStep", title: "Coffee Intake", question: "How many cups of coffee did you have today?", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you for tracking your coffee."
        summaryStep.text = "We appreciate your time (and caffeinated energy)!"
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-Coffee", steps: steps)
        
    }()
    
    /**
     Sample task created step-by-step!
    */
    static let sampleSurveyTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Experience Sampling Questionnaire"
        instructionStep.text = "This information will give us information about your mental and emotional state at various times throughout your workday, so that professional development activities can be most effectively administered."
        
        steps += [instructionStep]
        
        // OUTCOME 1: Belonging.
        
        // Question 1.1 - Sliding Scale of Belonging
        let belongingAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let belongingStep = ORKQuestionStep(identifier: "belongingQuestion", title: "Experience Sampling", question: "I feel like I belong in this space.", answer: belongingAnswer)
        
        steps += [belongingStep]
        
        // Question 1.2 - Sliding Scale of Connection to Coworkers
        let coworkerConnectionAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let coworkerConnectionStep = ORKQuestionStep(identifier: "corowkerConnectionQuestion", title: "Experience Sampling", question: "I feel connected to my co-workers.", answer: coworkerConnectionAnswer)
        
        steps += [coworkerConnectionStep]
        
        // OUTCOME 2: Stress
        
        // Question 2.1 - Sliding Scale of Stress
        let stressAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let stressStep = ORKQuestionStep(identifier: "stressQuestion", title: "Experience Sampling", question: "I currently feel stressed.", answer: stressAnswer)
        
        steps += [stressStep]
        
        // Question 2.2 - Sliding Scale of Overwhelmed
        let overwhelmedAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let overwhelmedStep = ORKQuestionStep(identifier: "overwhelmedQuestion", title: "Experience Sampling", question: "I currently feel overwhelmed.", answer: overwhelmedAnswer)
        
        steps += [overwhelmedStep]
        
        // OUTCOME 3: Environmental Sttitudes
        
        // Question 3.1 - Sliding Scale of Caring about Environment
        let environmentalAttitudesAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let environmentalAttitudesStep = ORKQuestionStep(identifier: "environmentalAttitudesQuestion", title: "Experience Sampling", question: "I care about the wellbeing of the environment I occupy.", answer: environmentalAttitudesAnswer)
        
        steps += [environmentalAttitudesStep]
        
        // Questoin 3.2 - Sliding Scale of Environmental Attunement
        let environmentalAttunementAnswer = ORKScaleAnswerFormat(maximumValue: 7, minimumValue: 1, defaultValue: 4, step: 1)
        let environmentalAttunementStep = ORKQuestionStep(identifier: "environmentalAttunementQuestion", title: "Experience Sampling", question: "I feel attuned to my environment.", answer: environmentalAttunementAnswer)
        
        steps += [environmentalAttunementStep]
        
        // OUTCOME 4: Creativity
        
        // Question 4.1 - Text Box for Creativity (will be evaluated by coders after the study)
        let creativityAnswer = ORKTextAnswerFormat()
        let creativityStep = ORKQuestionStep(identifier: "creativityQuestion", title: "Experience Sampling", question: "If you have seen a problem in a new way since your last experience sampling survey, explain in the box below.", answer: creativityAnswer)
        
        steps += [creativityStep]
        
        let task = ORKNavigableOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
        
        return task
    }()
}
