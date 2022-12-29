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
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Check if a consent document exists on the cloud, otherwise user will need to re-consent
        if let documentCollection = CKStudyUser.shared.authCollection {
            let config = CKPropertyReader(file: "CKConfiguration")
            let consentFileName = config.read(query: "Consent File Name") ?? "My Consent File"
            let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")

            guard let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last else {
                return
            }

            let url = docURL.appendingPathComponent("\(consentFileName).pdf")

            documentRef.write(toFile: url) { _, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.setAnswer(false)
                } else {
                    self.setAnswer(true)
                }
                super.goForward()
            }
        }
    }
}
