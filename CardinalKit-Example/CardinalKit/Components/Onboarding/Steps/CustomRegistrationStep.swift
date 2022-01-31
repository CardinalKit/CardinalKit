//
//  CustomRegistrationStep.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/31/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ResearchKit

struct CustomRegistrationStep {
    
    static let registrationForm: ORKFormStep = {
        
        let registrationStep = ORKFormStep(identifier: "registrationStep", title: "Registration", text: "Please provide your information for creating your user account.")
        
        let firstNameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
        firstNameAnswerFormat.multipleLines = false
        
        let lastNameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
        lastNameAnswerFormat.multipleLines = false
        
        let nameSectionTitle = ORKFormItem(sectionTitle: nil)
        let firstNameFormItem = ORKFormItem(identifier: "firstNameFormItem", text: "First Name", answerFormat: firstNameAnswerFormat)
        let lastNameFormItem = ORKFormItem(identifier: "lastNameFormItem", text: "Last Name", answerFormat: lastNameAnswerFormat)
        let dobAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: nil, minimumDate: nil, maximumDate: Date(), calendar: nil)
        let dobFormItem = ORKFormItem(identifier: "dobFormItem", text: "Date of Birth", answerFormat: dobAnswerFormat)
        
        registrationStep.formItems = [nameSectionTitle, firstNameFormItem, lastNameFormItem, dobFormItem]
        
        return registrationStep
        
    }()
    
}
