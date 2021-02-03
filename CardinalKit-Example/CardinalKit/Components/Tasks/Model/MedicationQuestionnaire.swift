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
struct MedicationQuestionnaire {
    
    /**
     Sample task template!
    */
    static let form: ORKNavigableOrderedTask = {
        
        var steps = [ORKStep]()
        
        /*
            CS342 -- ASSIGNMENT 2
            Add steps to the array above to create a survey!
         */
        
        // Q1
        let firstStepAnswerFormat = ORKBooleanAnswerFormat()
        let firstStep = ORKQuestionStep(identifier: "Q1", title: "Medications", question: "Do you have your medications currently?", answer: firstStepAnswerFormat)
        steps.append(firstStep)
        
        // Q2
        let secondStep = ORKQuestionStep(identifier: "Q2", title: "Medications", question: "How many medications do you currently take for heart problems?", answer: ORKAnswerFormat.decimalAnswerFormat(withUnit: nil))
        steps.append(secondStep)
        
        // Q3
        let thirdStepAnswerFormat = ORKBooleanAnswerFormat()
        let thirdStep = ORKQuestionStep(identifier: "Q3", title: "Medications", question: "Have you stopped taking any medications for heart problems in the last 6 months?", answer: thirdStepAnswerFormat)
        thirdStep.isOptional = false
        steps.append(thirdStep)
        
        // automatically generate stopped form for 5 drugs
        for index in 0...5 {
            // Q4
            let stoppedStep = ORKFormStep(identifier: "Q4-\(index)", title: "Stopped Drug \(index + 1)", text: "What heart medication was stopped?")
            
            // name of the drug
            let drugNameAnswerFormat = ORKAnswerFormat.textAnswerFormat()
            let drugNameSection = ORKFormItem(sectionTitle: "Please enter the name of the drug:")
            let drugNameQ = ORKFormItem(identifier: "Q4-drug-\(index)", text: nil, answerFormat: drugNameAnswerFormat)
            
            // reason it was stopped
            let drugDateAnswerFormat = ORKAnswerFormat.textAnswerFormat()
            let drugDateSection = ORKFormItem(sectionTitle: "Reason it was stopped:")
            let drugDateQ = ORKFormItem(identifier: "Q4-reason-\(index)", text: nil, answerFormat: drugDateAnswerFormat)
            
            stoppedStep.formItems = [
                drugNameSection,
                drugNameQ,
                drugDateSection,
                drugDateQ
            ]
            steps.append(stoppedStep)
            
            if index < 5 {
                // Check if we have more stopped drugs to report
                let extraDrugStep = ORKQuestionStep(identifier: "MoreStopped?-\(index)", title: "", question: "Have you stopped taking any other drugs?", answer: ORKBooleanAnswerFormat())
                extraDrugStep.isOptional = false
                steps.append(extraDrugStep)
            }
        }
        
        
        // automatically generate forms for 20 drugs
        for index in 0...20 {
            // build out the form for a specific drug
            let drugStep = ORKFormStep(identifier: "drug-entry-\(index)", title: "Current Drug \(index + 1)", text: "Enter a medication that you currently take for high blood pressure")
            
            // name of the drug
            let drugNameAnswerFormat = ORKAnswerFormat.textAnswerFormat()
            let drugNameSection = ORKFormItem(sectionTitle: "Please enter the name of the drug")
            let drugNameQ = ORKFormItem(identifier: "drug-name-\(index)", text: nil, answerFormat: drugNameAnswerFormat)
            
            // how often
            let prescribedFrequencyChoices = [
                ORKTextChoice(text: "Every Day", detailText: nil, value: 1 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "As Needed", detailText: nil, value: 2 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Don't Know", detailText: nil, value: 3 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
            ]
            let prescribedFrequencyAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: prescribedFrequencyChoices)
            let prescribedFrequencyQ = ORKFormItem(identifier: "prescribed-frequency-\(index)", text: "How often does your doctor want you you to take this drug?", answerFormat: prescribedFrequencyAnswerFormat)
            
            // intention of the drug
            let drugIntentChoices = [
                ORKTextChoice(text: "Get rid of water", detailText: nil, value: 1 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
                ORKTextChoice(text: "Lower my pressure", detailText: nil, value: 2 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
                ORKTextChoice(text: "Prevent a stroke", detailText: nil, value: 3 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
                ORKTextChoice(text: "Prevent heart problems", detailText: nil, value: 4 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
                ORKTextChoice(text: "Relieve headaches", detailText: nil, value: 5 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false),
                ORKTextChoice(text: "Don't know", detailText: nil, value: 7 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: 6 as NSCoding & NSCopying & NSObjectProtocol, exclusive: false, textViewPlaceholderText: "Other")
            ]
            let drugIntentAnswerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: drugIntentChoices)
            let drugIntentQ = ORKFormItem(identifier: "drug-intention-\(index)", text: "How is this drug supposed to help you?  (Select all that apply)", answerFormat: drugIntentAnswerFormat)
            
            let numDaysTakenAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 7, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "days", minimumValueDescription: nil)
            let numDaysTakenQ = ORKFormItem(identifier: "num-days-taken-\(index)", text: "In the past week, how many days did you take this drug?", answerFormat: numDaysTakenAnswerFormat)
            
            let timesPerDayAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "doses per day", minimumValueDescription: nil)
            let timesPerDayQ = ORKFormItem(identifier: "doses-per-day-\(index)", text: "In the past week, how many times per day did you take this drug?", answerFormat: timesPerDayAnswerFormat)
            
            let pillsPerDoseAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "pills per dose", minimumValueDescription: nil)
            let pillsPerDoseQ = ORKFormItem(identifier: "pills-per-dose-\(index)", text: "When you take this drug, how many pills do you consume at once?", answerFormat: pillsPerDoseAnswerFormat)
            
            let missedDoseAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 7, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "times", minimumValueDescription: nil)
            let missedDoseQ = ORKFormItem(identifier: "times-missed-\(index)", text: "How many times did you miss taking this drug?", answerFormat: missedDoseAnswerFormat)
            
            let effectivenessChoices = [
                ORKTextChoice(text: "Not well at all", detailText: nil, value: 1 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Moderately well", detailText: nil, value: 2 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Very well", detailText: nil, value: 3 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Don't know", detailText: nil, value: 4 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
            ]
            let effectivenessAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: effectivenessChoices)
            let effectivenessQ = ORKFormItem(identifier: "perceived-effectiveness-\(index)", text: "How well does this drug work for you?", answerFormat: effectivenessAnswerFormat)
            
            let botherChoices = [
                ORKTextChoice(text: "Not at all", detailText: nil, value: 1 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Bothers a little", detailText: nil, value: 2 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Bothers a lot", detailText: nil, value: 3 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: "Don't know", detailText: nil, value: 4 as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
            ]
            let botherAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: botherChoices)
            let botherQ = ORKFormItem(identifier: "bother-index-\(index)", text: "How much does this drug bother you?", answerFormat: botherAnswerFormat)
            
            
            // difficulty section
            let rememberDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let rememberDifficultyQ = ORKFormItem(identifier: "difficulty-remember-\(index)", text: "How much difficulty are you having remembering all the doses?", answerFormat: rememberDifficultyFormat)
            
            let payDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let payDifficultyQ = ORKFormItem(identifier: "difficulty-pay-\(index)", text: "How much difficulty are you having paying for this drug?", answerFormat: payDifficultyFormat)
            
            let refillDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let refillDifficultyQ = ORKFormItem(identifier: "difficulty-refill-\(index)", text: "How much difficulty are you having getting your refill on time?", answerFormat: refillDifficultyFormat)
            
            let sideEffectDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let sideEffectDifficultyQ = ORKFormItem(identifier: "difficulty-side-effect-\(index)", text: "How many unwanted side effects are you experiencing?", answerFormat: sideEffectDifficultyFormat)
            
            let longTermEffectDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let longTermEffectDifficultyQ = ORKFormItem(identifier: "difficulty-long-effect-\(index)", text: "I worry about the long term effects of this drug", answerFormat: longTermEffectDifficultyFormat)
            
            let otherConcernsDifficultyFormat = ORKAnswerFormat.scale(withMaximumValue: 3, minimumValue: 0, defaultValue: 0, step: 1, vertical: false, maximumValueDescription: "A lot", minimumValueDescription: "A little")
            let otherConcernsDifficultyQ = ORKFormItem(identifier: "difficulty-other-\(index)", text: "This drug causes other concerns or problems", answerFormat: otherConcernsDifficultyFormat)
            
            drugStep.formItems = [
                drugNameSection,
                drugNameQ,
                prescribedFrequencyQ,
                drugIntentQ,
                numDaysTakenQ,
                timesPerDayQ,
                pillsPerDoseQ,
                missedDoseQ,
                effectivenessQ,
                botherQ,
                rememberDifficultyQ,
                payDifficultyQ,
                refillDifficultyQ,
                sideEffectDifficultyQ,
                longTermEffectDifficultyQ,
                otherConcernsDifficultyQ
            ]
            steps.append(drugStep)
            
            if index < 20 {
                // Check if we have more drugs to report
                let extraDrugStep = ORKQuestionStep(identifier: "MoreDrugs?-\(index)", title: "", question: "Do you have any other current medications?", answer: ORKBooleanAnswerFormat())
                extraDrugStep.isOptional = false
                steps.append(extraDrugStep)
            }
        }
        
        // Thank you page
        let summaryStep = ORKInstructionStep(identifier: "SummaryStep")
        summaryStep.title = "Drug Form Complete"
        summaryStep.text = "Thank you for completing the survey."
        summaryStep.image = UIImage(named: "Portrait")
        steps.append(summaryStep)
        
        let ret_value = ORKNavigableOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
        
        // rules for drug forms
        for index in 0...19 {
            // Navigation Rule
            let resultSelector = ORKResultSelector(resultIdentifier: "MoreDrugs?-\(index)")
            let predicateAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
            
            let predicateRule = ORKPredicateStepNavigationRule(resultPredicates: [predicateAnswerType], destinationStepIdentifiers: ["drug-entry-\(index + 1)"], defaultStepIdentifier: "SummaryStep", validateArrays: true)
            
            ret_value.setNavigationRule(predicateRule, forTriggerStepIdentifier: "MoreDrugs?-\(index)")
        }
        
        // rules for stopped drug forms
        for index in 0...4 {
            let resultSelector = ORKResultSelector(resultIdentifier: "MoreStopped?-\(index)")
            let predicateAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)

            let predicateRule = ORKPredicateStepNavigationRule(resultPredicates: [predicateAnswerType], destinationStepIdentifiers: ["Q4-\(index + 1)"], defaultStepIdentifier: "drug-entry-0", validateArrays: true)
            
            ret_value.setNavigationRule(predicateRule, forTriggerStepIdentifier: "MoreStopped?-\(index)")
        }
        
        // rule for stopping any drugs
        let resultSelector = ORKResultSelector(resultIdentifier: "Q3")
        let predicateAnswerType = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
        
        let predicateRule = ORKPredicateStepNavigationRule(resultPredicates: [predicateAnswerType], destinationStepIdentifiers: ["Q4-0"], defaultStepIdentifier: "drug-entry-0", validateArrays: true)
        ret_value.setNavigationRule(predicateRule, forTriggerStepIdentifier: "Q3")
        
        return ret_value
    }()
}
