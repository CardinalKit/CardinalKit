//
//  LoginStep.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

class PasswordlessLoginStep: ORKFormStep {
    static let identifier = "Login"
    
    static let idStepIdentifier = "IdStep"
    static let idConfirmStepIdentifier = "ConfirmIdStep"
    
    override init(identifier: String) {
        super.init(identifier: identifier)
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        title = config.read(query: "Login Step Title") ?? "Almost done!"
        text = config.read(query: "Login Step Text") ?? "We need to confirm your email address and send you a copy of the consent you just signed."
        
        formItems = createFormItems()
        isOptional = false
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     This function creates a form with the exact email question to ask.
     
     - Returns a `ORKFormItem` array with questions to show.
    */
    fileprivate func createFormItems() -> [ORKFormItem] {
        let idStepTitle = "Email:"
        
        let titleStep = ORKFormItem(sectionTitle: "✉️ 🌎")
        
        let idQuestionStep = ORKFormItem(
            identifier: PasswordlessLoginStep.idStepIdentifier,
            text: idStepTitle,
            answerFormat: ORKEmailAnswerFormat(),
            optional: false
        )
        
        return [titleStep, idQuestionStep]
    }
}
