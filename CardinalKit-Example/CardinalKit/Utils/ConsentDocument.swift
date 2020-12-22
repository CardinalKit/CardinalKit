//
//  ConsentDocument.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties
    
    override init() {
        super.init()
        
        let config = CKPropertyReader(file: "CKConfiguration")
        
        let consentTitle = config.read(query: "Consent Title")
        
        title = NSLocalizedString(consentTitle, comment: "")
        
        let sectionTypes: [ORKConsentSectionType] = [
            .overview,
            .dataGathering,
            .privacy,
            .dataUse,
            .timeCommitment,
            .studySurvey,
            .studyTasks,
            .withdrawing
        ]
        
        let keys = ["Overview", "Data Gathering", "Privacy", "Data Use", "Time Commitment", "Study Survey", "Study Tasks", "Withdrawing"]
        
        let consentForm = config.readDict(query: "Consent Form")
        sections = []
        
        for sectionType in keys {
            let section = ORKConsentSection(type: sectionTypes[keys.index(of: sectionType)!])
            
            if let consentSectionText = consentForm[sectionType] {
                let localizedStep = NSLocalizedString(consentSectionText, comment: "")
                let localizedSummary = localizedStep.components(separatedBy: ".")[0] + "."
                
                section.summary = localizedSummary
                section.content = localizedStep
                if sections == nil {
                    sections = [section]
                } else {
                    sections!.append(section)
                }
            }
        }
        
        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        signature.title = title
        signaturePageTitle = title
        addSignature(signature)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .overview:
            return "Overview"
            
        case .dataGathering:
            return "DataGathering"
            
        case .privacy:
            return "Privacy"
            
        case .dataUse:
            return "DataUse"
            
        case .timeCommitment:
            return "TimeCommitment"
            
        case .studySurvey:
            return "StudySurvey"
            
        case .studyTasks:
            return "StudyTasks"
            
        case .withdrawing:
            return "Withdrawing"
            
        case .custom:
            return "Custom"
            
        case .onlyInDocument:
            return "OnlyInDocument"
        }
    }
}
