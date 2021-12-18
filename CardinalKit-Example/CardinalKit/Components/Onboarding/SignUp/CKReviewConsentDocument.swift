//
//  CKReviewConsentDocument.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 16/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Firebase
import ResearchKit


public class CKReviewConsentDocument: ORKQuestionStep{
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
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // REVIEW IF DOCUMENT EXIST
        if let DocumentCollection = CKStudyUser.shared.authCollection {
            let config = CKPropertyReader(file: "CKConfiguration")
            let DocumentRef = storageRef.child("\(DocumentCollection)/Consent.pdf")
            // Create local filesystem URL
            var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last as NSURL?
            docURL = docURL?.appendingPathComponent("\(config.read(query: "Consent File Name")).pdf") as NSURL?
            let url = docURL! as URL
            // Download to the local filesystem
            let downloadTask = DocumentRef.write(toFile: url) { url, error in
              if let error = error {
                // Uh-oh, an error occurred!
                  self.setAnswer(false)
              } else {
                  self.setAnswer(true)
                  
              }
                super.goForward()
            }
        }
        
        // SELF IF DOCUMENT EXIST
       
    }
}
