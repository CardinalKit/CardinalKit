//
//  CKVerifyConsentDocument.swift
//
//  Created for the CardinalKit framework.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Firebase
import Foundation
import ResearchKit


public class CKVerifyConsentDocumentStep: ORKQuestionStep {
    override public init(
        identifier: String
    ) {
        super.init(identifier: identifier)
        self.answerFormat = ORKAnswerFormat.booleanAnswerFormat()
    }
    
    @available(*, unavailable)
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class CKVerifyConsentDocumentStepViewController: ORKQuestionStepViewController {
    public var CKVerifyConsentDocumentStep: CKVerifyConsentDocumentStep? {
        step as? CKVerifyConsentDocumentStep
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Downloads the user's consent file from Cloud Storage.
        // If a consent doesn't exist, the next step will ask the user to sign it.
        Task {
            let manager = CKConsentManager()
            let result = await manager.verifyConsent()
            self.setAnswer(result)
            super.goForward()
        }
    }
}
