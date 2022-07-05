//
//  CKReviewConsentDocument.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 16/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

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

public class CKReviewConsentDocumentViewController:ORKQuestionStepViewController{
    public var CKReviewConsentDocument: CKReviewConsentDocument!{
        return step as? CKReviewConsentDocument
    }
    
    public override func viewDidLoad() {
        // Check if a consent document exists on the cloud, otherwise user will need to re-consent
        if let DocumentCollection = CKStudyUser.shared.authCollection {
            let config = CKPropertyReader(file: "CKConfiguration")
            let consentFileName = config.read(query: "Consent File Name")
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
            docURL = docURL?.appendingPathComponent("\(consentFileName).pdf") as NSURL?
            let url = docURL! as URL
            let networkLibrary = Dependencies.container.resolve(NetworkingLibrary.self)!
            
            networkLibrary.checkIfFileExist(url: url, path: "\(DocumentCollection)/\(consentFileName).pdf", onComplete: {
                exist in
                self.setAnswer(exist)
                super.goForward()
            })
        }
        else{
            self.setAnswer(false)
            super.goForward()
        }
    }
}
