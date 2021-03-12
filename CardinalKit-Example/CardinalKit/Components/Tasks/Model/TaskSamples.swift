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
