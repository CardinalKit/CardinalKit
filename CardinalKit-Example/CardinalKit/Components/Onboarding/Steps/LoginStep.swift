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
        
        // TODO: make configurable
        title = NSLocalizedString("Almost done!", comment: "")
        text = NSLocalizedString("We need to confirm your email address and send you a copy of the consent you just signed.", comment: "")
        
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
