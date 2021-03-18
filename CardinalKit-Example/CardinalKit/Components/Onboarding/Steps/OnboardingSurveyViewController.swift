//
//  OnboardingSurveyViewController.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//
import ResearchKit

class OnboardingSurveyStep: ORKFormStep {
    
    static let identifier = "Survey"
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        title = NSLocalizedString(config.read(query: "Onboarding Survey Title"), comment: "")
        text = NSLocalizedString(config.read(query: "Onboarding Survey Text"), comment: "")
        
        formItems = createFormItems()
        isOptional = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createFormItems() -> [ORKFormItem] {
        var steps = [ORKStep]()
        
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
        
        let medicalTitle = ORKFormItem(sectionTitle: "Medical Onboarding Questions")
        
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

        return [ageFormItem, genderFormItem, ethnicityFormItem, medicalTitle, dateFormItem, diseaseCauseFormItem, comorbiditiesFormItem]
    }
    
}
