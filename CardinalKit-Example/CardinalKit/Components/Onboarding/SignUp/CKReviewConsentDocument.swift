//
//  CKReviewConsentDocument.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 16/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Firebase
import Foundation
import ResearchKit


public class CKReviewConsentDocument: ORKQuestionStep {
    public override init(
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

public class CKReviewConsentDocumentViewController: ORKQuestionStepViewController {
    public var CKReviewConsentDocument: CKReviewConsentDocument! {
        step as? CKReviewConsentDocument
    }
    
    override public func viewDidLoad() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Check if a consent document exists on the cloud, otherwise user will need to re-consent
        if let documentCollection = CKStudyUser.shared.authCollection {
            let config = CKPropertyReader(file: "CKConfiguration")
            let consentFileName = config.read(query: "Consent File Name")
            let documentRef = storageRef.child("\(documentCollection)/\(consentFileName).pdf")
            
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
            docURL = docURL?.appendingPathComponent("\(consentFileName).pdf") as NSURL?
            let url = docURL! as URL
            
            documentRef.write(toFile: url) { url, error in
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
