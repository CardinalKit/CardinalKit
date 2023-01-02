//
//  CKInstructionSteps.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/1/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//

import ResearchKit


struct CKInstructionSteps {
    /// Creates individual instruction steps that summarize the sections in the study consent,
    /// with titles and text pulled from CKConfiguration.plist.
    ///
    /// This may be replaced with your own custom instruction steps for your onboarding workflow.
    static var steps: [ORKInstructionStep] = {
        let config = CKConfig.shared
        let instructionSteps = config["Consent Form"] as? [String: [String: String]]

        let stepKeys = [
            "Overview",
            "DataGathering",
            "Privacy",
            "DataUse",
            "TimeCommitment",
            "StudySurvey",
            "StudyTasks"
        ]

        var steps = [ORKInstructionStep]()

        for key in stepKeys {
            guard let title = instructionSteps?[key]?["Title"],
                  let summary = instructionSteps?[key]?["Summary"] else {
                continue
            }
            let step = ORKInstructionStep(identifier: "\(key)Step")
            step.title = title
            step.text = summary
            steps.append(step)
        }

        return steps
    }()
}
