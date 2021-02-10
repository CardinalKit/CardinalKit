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
        
        return ORKOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
    }()
    
    /**
        A2 Steps - Kabir
            Credit to Apple's ORKCatalogSample app as a reference for the code used to create the survey below
     */
    static let onboardingSurveyTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
//        let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "Not now")
//        let booleanStep = ORKQuestionStep(identifier: "AreYouReady-Boolean", title: "Before we get started...", question: "Are you ready to start the test?", answer: booleanAnswer)
//
//        steps += [booleanStep]
        
        // About you
        // Age
        let numberAnswerFormat = ORKNumericAnswerFormat(style: .integer, unit: nil, minimum: 0 as NSNumber, maximum: 120 as NSNumber)
        let ageFormItem = ORKFormItem(identifier: "OnboardingForm-Age", text: "How old are you?", answerFormat: numberAnswerFormat, optional: false)
        ageFormItem.placeholder = NSLocalizedString("Enter your age here", comment: "")
        
        // Gender
        let genderChoiceOneText = NSLocalizedString("Male", comment: "")
        let genderChoiceTwoText = NSLocalizedString("Female", comment: "")
        let genderChoiceThreeText = NSLocalizedString("Non-conforming", comment: "")
        let genderChoiceFourText = NSLocalizedString("Male Transgender", comment: "")
        let genderChoiceFiveText = NSLocalizedString("Female Transgender", comment: "")
        let genderChoiceSixText = NSLocalizedString("Other", comment: "")
        let genderChoices = [
            ORKTextChoice(text: genderChoiceOneText, value: "male" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: genderChoiceTwoText, value: "female" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: genderChoiceThreeText, value: "non-conforming" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: genderChoiceFourText, value: "male-transgender" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: genderChoiceFiveText, value: "female-transgender" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoiceOther.choice(withText: genderChoiceSixText, detailText: nil, value: "other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Enter text here")
        ]
        let genderAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: genderChoices)
        let genderFormItem = ORKFormItem(identifier: "OnboardingForm-Gender", text: "What is your preferred gender: ", answerFormat: genderAnswerFormat, optional: false)
        
        // Ethnicity
        let ethnicityChoiceOneText = NSLocalizedString("White", comment: "")
        let ethnicityChoiceTwoText = NSLocalizedString("Hispanic or Latino", comment: "")
        let ethnicityChoiceThreeText = NSLocalizedString("Black or African American", comment: "")
        let ethnicityChoiceFourText = NSLocalizedString("Native American or American Indian", comment: "")
        let ethnicityChoiceFiveText = NSLocalizedString("Asian/Pacific Islander", comment: "")
        let ethnicityChoiceSixText = NSLocalizedString("Other", comment: "")
        let ethnicityChoices = [
            ORKTextChoice(text: ethnicityChoiceOneText, value: "white" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: ethnicityChoiceTwoText, value: "hispanic-latino" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: ethnicityChoiceThreeText, value: "black-african-american" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: ethnicityChoiceFourText, value: "native-american-american-indian" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: ethnicityChoiceFiveText, value: "asian-pacific-islander" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoiceOther.choice(withText: ethnicityChoiceSixText, detailText: nil, value: "other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Enter text here")
        ]
        let ethnicityAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: ethnicityChoices)
        let ethnicityFormItem = ORKFormItem(identifier: "OnboardingForm-Ethnicity", text: "Ethnicity", answerFormat: ethnicityAnswerFormat, optional: false)
        
        let onboardingFormStep = ORKFormStep(identifier: "OnboardingForm", title: "About You", text: "")
        onboardingFormStep.formItems = [ageFormItem, genderFormItem, ethnicityFormItem]
        steps += [onboardingFormStep]
        
        // Medical Onboarding Questions
        let dateAnswerFormat = ORKDateAnswerFormat(style: .date)
        let dateFormItem = ORKFormItem(identifier: "RegistrationForm-DateQuestion", text: "When did you have the surgery?", answerFormat: dateAnswerFormat)
        
        let diseaseCauseChoiceOneText = NSLocalizedString("Diabetes", comment: "")
        let diseaseCauseChoiceTwoText = NSLocalizedString("High Blood Pressure", comment: "")
        let diseaseCauseChoiceThreeText = NSLocalizedString("Glomerulonephritis", comment: "")
        let diseaseCauseChoiceFourText = NSLocalizedString("Polycystic Kidney Disease", comment: "")
        let diseaseCauseChoiceFiveText = NSLocalizedString("Obstruction", comment: "")
        let diseaseCauseChoiceSixText = NSLocalizedString("Unknown", comment: "")
        let diseaseCauseChoiceSevenText = NSLocalizedString("I do not know", comment: "")
        let diseaseCauseChoiceEightText = NSLocalizedString("Other", comment: "")
        let diseaseCauseChoices = [
            ORKTextChoice(text: diseaseCauseChoiceOneText, value: "diabetes" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceTwoText, value: "high-blood-pressure" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceThreeText, value: "glomerulonephritis" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceFourText, value: "polycystic-kidney-disease" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceFiveText, value: "obstruction" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceSixText, value: "unknown" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: diseaseCauseChoiceSevenText, value: "dont-know" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoiceOther.choice(withText: diseaseCauseChoiceEightText, detailText: nil, value: "other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Enter text here")
        ]
        let diseaseCauseAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: diseaseCauseChoices)
        let diseaseCauseFormItem = ORKFormItem(identifier: "MedicalOnboardingForm-Cause", text: "Cause of kidney disease?", answerFormat: diseaseCauseAnswerFormat, optional: false)
        
        let comorbidities = ["Diabetes", "Hypertension", "Congestive Heart Failure", "COPD", "Other"]
        var comorbiditiesChoices = [ORKTextChoice]()
        for comorbidity in comorbidities {
            let comorbiditiesChoiceText = NSLocalizedString(comorbidity, comment: "")
            if comorbidity != "Other" {
                let comorbiditiesChoice = ORKTextChoice(text: comorbiditiesChoiceText, value: comorbidity.lowercased().filter {!$0.isWhitespace} as NSCoding & NSCopying & NSObjectProtocol)
                comorbiditiesChoices.append(comorbiditiesChoice)
            } else {
                let comorbiditiesChoice = ORKTextChoiceOther.choice(withText: comorbiditiesChoiceText, detailText: nil, value: comorbidity.lowercased().filter {!$0.isWhitespace} as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Enter text here")
                comorbiditiesChoices.append(comorbiditiesChoice)
            }
        }
//        let comorbiditiesChoiceOneText = NSLocalizedString("Diabetes", comment: "")
//        let comorbiditiesChoiceTwoText = NSLocalizedString("Hypertension", comment: "")
//        let comorbiditiesChoiceThreeText = NSLocalizedString("Congestive Heart Failure", comment: "")
//        let comorbiditiesChoiceFourText = NSLocalizedString("COPD", comment: "")
//        let comorbiditiesChoiceFiveText = NSLocalizedString("Other", comment: "")
//        let comorbiditiesChoices = [
//            ORKTextChoice(text: comorbiditiesChoiceOneText, value: "diabetes" as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: comorbiditiesChoiceTwoText, value: "choice_2" as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: comorbiditiesChoiceThreeText, value: "choice_3" as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoice(text: comorbiditiesChoiceFourText, value: "choice_4" as NSCoding & NSCopying & NSObjectProtocol),
//            ORKTextChoiceOther.choice(withText: comorbiditiesChoiceFiveText, detailText: nil, value: "choice_5" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Enter text here")
//        ]
        let comorbiditiesAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: comorbiditiesChoices)
        let comorbiditiesFormItem = ORKFormItem(identifier: "MedicalOnboardingForm-Comorbidities", text: "What related conditions (comorbidities) do you have?", answerFormat: comorbiditiesAnswerFormat, optional: false)
        
        let medicalOnboardingFormStep = ORKFormStep(identifier: "MedicalOnboardingForm", title: "Kidney-Related Medical Questions", text: "")
        medicalOnboardingFormStep.formItems = [dateFormItem, diseaseCauseFormItem, comorbiditiesFormItem]
        steps += [medicalOnboardingFormStep]

        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "All done!"
        steps += [summaryStep]

        let task = ORKNavigableOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)

        let resultBooleanSelector = ORKResultSelector(resultIdentifier: onboardingFormStep.identifier)
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultBooleanSelector, expectedAnswer: true)
        let navigableRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicate, summaryStep.identifier)])
        task.setNavigationRule(navigableRule, forTriggerStepIdentifier: onboardingFormStep.identifier)

        return task
    }()
    
    /**
     Sample task template!
    */
    static let sf12SurveyTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        /*
            CS342 -- ASSIGNMENT 2
            Add steps to the array above to create a survey!
         */
        
        // Question 1
        let q1textChoiceOneText = NSLocalizedString("Excellent (1)", comment: "")
        let q1textChoiceTwoText = NSLocalizedString("Very Good (2)", comment: "")
        let q1textChoiceThreeText = NSLocalizedString("Good (3)", comment: "")
        let q1textChoiceFourText = NSLocalizedString("Fair (4)", comment: "")
        let q1textChoiceFiveText = NSLocalizedString("Poor (5)", comment: "")
        
        let q1textChoices = [
            ORKTextChoice(text: q1textChoiceOneText, value: "Excellent (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceTwoText, value: "Very Good (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceThreeText, value: "Good (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFourText, value: "Fair (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFiveText, value: "Poor (5)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q1AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q1textChoices)
        
        let q1QuestionStep = ORKQuestionStep(identifier: "Q1", title: "Question 1", question: "In general, would you say your health is:", answer: q1AnswerFormat)
        
        q1QuestionStep.isOptional = false
        steps += [q1QuestionStep]
        
        // Question 2 and 3
        let q2q3textChoiceOneText = NSLocalizedString("Yes, Limited A Lot (1)", comment: "")
        let q2q3textChoiceTwoText = NSLocalizedString("Yes, Limited A Little (2)", comment: "")
        let q2q3textChoiceThreeText = NSLocalizedString("No, Not Limited At All (3)", comment: "")
        
        let q2q3textChoices = [
            ORKTextChoice(text: q2q3textChoiceOneText, value: "Yes, Limited A Lot (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q2q3textChoiceTwoText, value: "Yes, Limited A Little (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q2q3textChoiceThreeText, value: "No, Not Limited At All (3)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q2q3AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q2q3textChoices)
        
        let q2FormItem = ORKFormItem(identifier: "Q2", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: q2q3AnswerFormat)
        q2FormItem.isOptional = false
        
        let q3FormItem = ORKFormItem(identifier: "Q3", text: "Climbing SEVERAL flights of stairs:", answerFormat: q2q3AnswerFormat)
        q3FormItem.isOptional = false
        

        let q2q3FormStep = ORKFormStep(identifier: "q2q3", title: "Questions 2 and 3", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
        q2q3FormStep.formItems = [q2FormItem, q3FormItem]
        q2q3FormStep.isOptional = false
        steps += [q2q3FormStep]
        
        // Question 4 and 5
        let q4q5textChoiceOneText = NSLocalizedString("Yes (1)", comment: "")
        let q4q5textChoiceTwoText = NSLocalizedString("No (2)", comment: "")
        
        let q4q5textChoices = [
            ORKTextChoice(text: q4q5textChoiceOneText, value: "Yes (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q4q5textChoiceTwoText, value: "No (2)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q4q5AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q4q5textChoices)
        
        let q4FormItem = ORKFormItem(identifier: "Q4", text: "ACCOMPLISHED LESS than you would like:", answerFormat: q4q5AnswerFormat)
        q4FormItem.isOptional = false
        
        let q5FormItem = ORKFormItem(identifier: "Q5", text: "Were limited in the KIND of work or other activities:", answerFormat: q4q5AnswerFormat)
        q5FormItem.isOptional = false
        

        let q4q5FormStep = ORKFormStep(identifier: "q4q5", title: "Questions 4 and 5", text: "During the PAST 4 WEEKS have you had any of the following problems with your work or other regular activities AS A RESULT OF YOUR PHYSICAL HEALTH?")
        q4q5FormStep.formItems = [q4FormItem, q5FormItem]
        q4q5FormStep.isOptional = false
        steps += [q4q5FormStep]
        
        // Question 6 and 7
        let q6q7textChoiceOneText = NSLocalizedString("Yes (1)", comment: "")
        let q6q7textChoiceTwoText = NSLocalizedString("No (2)", comment: "")
        
        let q6q7textChoices = [
            ORKTextChoice(text: q6q7textChoiceOneText, value: "Yes (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q6q7textChoiceTwoText, value: "No (2)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q6q7AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q6q7textChoices)
        
        let q6FormItem = ORKFormItem(identifier: "Q6", text: "ACCOMPLISHED LESS than you would like:", answerFormat: q6q7AnswerFormat)
        q6FormItem.isOptional = false
        
        let q7FormItem = ORKFormItem(identifier: "Q7", text: "Didn’t do work or other activities as CAREFULLY as usual:", answerFormat: q6q7AnswerFormat)
        q7FormItem.isOptional = false
        

        let q6q7FormStep = ORKFormStep(identifier: "q6q7", title: "Questions 6 and 7", text: "During the PAST 4 WEEKS, were you limited in the kind of work you do or other regular activities AS A RESULT OF ANY EMOTIONAL PROBLEMS (such as feeling depressed or anxious)?")
        q6q7FormStep.formItems = [q6FormItem, q7FormItem]
        q6q7FormStep.isOptional = false
        steps += [q6q7FormStep]
        
        // Question 8
        let q8textChoiceOneText = NSLocalizedString("Not At All (1)", comment: "")
        let q8textChoiceTwoText = NSLocalizedString("A Little Bit (2)", comment: "")
        let q8textChoiceThreeText = NSLocalizedString("Moderately (3)", comment: "")
        let q8textChoiceFourText = NSLocalizedString("Quite A Bit (4)", comment: "")
        let q8textChoiceFiveText = NSLocalizedString("Extremely (5)", comment: "")
        
        let q8textChoices = [
            ORKTextChoice(text: q1textChoiceOneText, value: "Not At All (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceTwoText, value: "A Little Bit (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceThreeText, value: "Moderately (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFourText, value: "Quite A Bit (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q1textChoiceFiveText, value: "Extremely (5)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q8AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q8textChoices)
        
        let q8QuestionStep = ORKQuestionStep(identifier: "Q8", title: "Question 8", question: "During the PAST 4 WEEKS, how much did PAIN interfere with your normal work (including both work outside the home and housework)?", answer: q8AnswerFormat)
        
        q8QuestionStep.isOptional = false
        steps += [q8QuestionStep]
        
        // Question 9, 10, and 11
        let q9q10q11textChoiceOneText = NSLocalizedString("All of the Time (1)", comment: "")
        let q9q10q11textChoiceTwoText = NSLocalizedString("Most of the Time (2)", comment: "")
        let q9q10q11textChoiceThreeText = NSLocalizedString("A Good Bit of the Time (3)", comment: "")
        let q9q10q11textChoiceFourText = NSLocalizedString("Some of the Time (4)", comment: "")
        let q9q10q11textChoiceFiveText = NSLocalizedString("A Little of the Time (5)", comment: "")
        let q9q10q11textChoiceSixText = NSLocalizedString("None of the Time (6)", comment: "")
        
        let q9q10q11textChoices = [
            ORKTextChoice(text: q9q10q11textChoiceOneText, value: "All of the Time (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceTwoText, value: "Most of the Time (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceThreeText, value: "A Good Bit of the Time (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFourText, value: "Some of the Time (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFiveText, value: "A Little of the Time (5)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceSixText, value: "None of the Time (6)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q9q10q11AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q9q10q11textChoices)
        
        let q9FormItem = ORKFormItem(identifier: "Q9", text: "Have you felt calm and peaceful?", answerFormat: q9q10q11AnswerFormat)
        q6FormItem.isOptional = false
        
        let q10FormItem = ORKFormItem(identifier: "Q10", text: "Did you have a lot of energy?", answerFormat: q9q10q11AnswerFormat)
        q10FormItem.isOptional = false
        
        let q11FormItem = ORKFormItem(identifier: "Q11", text: "Have you felt downhearted and blue?", answerFormat: q9q10q11AnswerFormat)
        q11FormItem.isOptional = false
        

        let q9q10q11FormStep = ORKFormStep(identifier: "q9q10q11", title: "Questions 9, 10, and 11", text: "The next three questions are about how you feel and how things have been DURING THE PAST 4 WEEKS. For each question, please give the one answer that comes closest to the way you have been feeling. How much of the time during the PAST 4 WEEKS –")
        q9q10q11FormStep.formItems = [q9FormItem, q10FormItem, q11FormItem]
        q9q10q11FormStep.isOptional = false
        steps += [q9q10q11FormStep]
        
        // Question 12
        let q12textChoiceOneText = NSLocalizedString("All of the Time (1)", comment: "")
        let q12textChoiceTwoText = NSLocalizedString("Most of the Time (2)", comment: "")
        let q12textChoiceThreeText = NSLocalizedString("A Good Bit of the Time (3)", comment: "")
        let q12textChoiceFourText = NSLocalizedString("Some of the Time (4)", comment: "")
        let q12textChoiceFiveText = NSLocalizedString("A Little of the Time (5)", comment: "")
        let q12textChoiceSixText = NSLocalizedString("None of the Time (6)", comment: "")
        
        let q12textChoices = [
            ORKTextChoice(text: q9q10q11textChoiceOneText, value: "All of the Time (1)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceTwoText, value: "Most of the Time (2)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceThreeText, value: "A Good Bit of the Time (3)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFourText, value: "Some of the Time (4)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceFiveText, value: "A Little of the Time (5)" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: q9q10q11textChoiceSixText, value: "None of the Time (6)" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        
        let q12AnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: q12textChoices)
        
        let q12QuestionStep = ORKQuestionStep(identifier: "Q12", title: "Question 12", question: "During the PAST 4 WEEKS, how much of the time has your PHYSICAL HEALTH OR EMOTIONAL PROBLEMS interfered with your social activities (like visiting with friends, relatives, etc.)? ", answer: q12AnswerFormat)
        
        q12QuestionStep.isOptional = false
        steps += [q12QuestionStep]
        
        // Summary step
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "All done!"
        steps += [summaryStep]
        
        let task = ORKNavigableOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
        return task
    }()
    
    static let gaitAndBalanceTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Gait and Balance Task
        let gaitAndBalanceTask = ORKOrderedTask.shortWalk(withIdentifier: "GaitAndBalance", intendedUseDescription: "This task will require you to walk a short distance for a fixed number for steps.", numberOfStepsPerLeg: 20, restDuration: 20, options: ORKPredefinedTaskOption())
        steps += gaitAndBalanceTask.steps
 
        // Summary step
        let summaryStep = ORKCompletionStep(identifier: "ActiveSummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "All done!"
        steps += [summaryStep]

        let task = ORKNavigableOrderedTask(identifier: "SurveyActiveTasks-Assessment", steps: steps)
        return task
    }()
    
    static let timedWalkTask: ORKOrderedTask = {
        var steps = [ORKStep]()
 
        // Timed Walk Task
        let walkTask = ORKOrderedTask.timedWalk(withIdentifier: "TimedWalk", intendedUseDescription: "This task will require you to walk a short distance for a fixed amount of time.", distanceInMeters: 100.0, timeLimit: 180.0, turnAroundTimeLimit: 180.0, includeAssistiveDeviceForm: true, options: ORKPredefinedTaskOption())
        steps += walkTask.steps
 
        // Summary step
        let summaryStep = ORKCompletionStep(identifier: "ActiveSummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "All done!"
        steps += [summaryStep]

        let task = ORKNavigableOrderedTask(identifier: "SurveyActiveTasks-Assessment", steps: steps)
        return task
    }()
}
