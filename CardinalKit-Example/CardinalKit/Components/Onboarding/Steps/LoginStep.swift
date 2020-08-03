//
//  LoginStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

class LoginStep: ORKFormStep {
    
    static let identifier = "Login"
    
    static let idStepIdentifier = "IdStep"
    static let idConfirmStepIdentifier = "ConfirmIdStep"
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        title = NSLocalizedString(config.read(query: "Login Step Title"), comment: "")
        text = NSLocalizedString(config.read(query: "Login Step Text"), comment: "")
        
        formItems = createFormItems()
        isOptional = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     This function creates a form with the exact email question to ask.
     
     - Returns a `ORKFormItem` array with questions to show.
    */
    fileprivate func createFormItems() -> [ORKFormItem] {
        let emailAnswerFormat = ORKEmailAnswerFormat()
        let idStepTitle = "Enter your email address:"
        let idQuestionStep = ORKFormItem(identifier: LoginStep.idStepIdentifier, text: idStepTitle, answerFormat: emailAnswerFormat, optional: false)
        
        return [idQuestionStep]
    }
    
}
