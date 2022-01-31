//
//  PersonalInformationStep.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/31/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import ResearchKit

struct PersonalInfoStep {
    
    static let form: ORKFormStep = {
        let config = CKPropertyReader(file: "CKConfiguration")

        let personalInfoStep = ORKFormStep(identifier: "personalInfoStep", title: "Registration", text: "Please provide your information for creating your user account.")
        
        let sectionTitle = ORKFormItem(sectionTitle: nil)
        
        var formItems: [ORKFormItem] = [sectionTitle]
        
        if config["Collect Personal Information"]["Name"] as? Bool == true {
            
            let firstNameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
            firstNameAnswerFormat.multipleLines = false
            
            let lastNameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
            lastNameAnswerFormat.multipleLines = false
            
            let firstNameFormItem = ORKFormItem(identifier: "firstNameFormItem", text: "First Name", answerFormat: firstNameAnswerFormat)
            let lastNameFormItem = ORKFormItem(identifier: "lastNameFormItem", text: "Last Name", answerFormat: lastNameAnswerFormat)
            
            formItems += [firstNameFormItem, lastNameFormItem]
            
        }
        
        if config["Collect Personal Information"]["DOB"] as? Bool == true {
            let dobAnswerFormat = ORKAnswerFormat.dateAnswerFormat(withDefaultDate: nil, minimumDate: nil, maximumDate: Date(), calendar: nil)
            let dobFormItem = ORKFormItem(identifier: "dobFormItem", text: "Date of Birth", answerFormat: dobAnswerFormat)
            
            formItems += [dobFormItem]
            
        }
        
        personalInfoStep.formItems = formItems
        return personalInfoStep
        
    }()
    
}
