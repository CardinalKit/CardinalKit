//
//  PainSurvey.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 2/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ResearchKit

struct PainSurvey {
    static let painSurvey: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        let answerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 0, defaultValue: 5, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "None")
        let painSurveyStep = ORKQuestionStep(identifier: "painSurvey", title: "Pain", question: "How much pain are you having?", answer: answerFormat)
        let surveyTask = ORKOrderedTask(identifier: "painSurvey", steps: [painSurveyStep])
        
        steps += [painSurveyStep]
        
        return ORKOrderedTask(identifier: "painTask", steps: steps)
    }()
}
