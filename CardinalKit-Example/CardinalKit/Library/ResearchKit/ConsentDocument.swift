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

        let config = CKConfig.shared
        title = config.read(query: "Consent Title") ?? "Consent Form"
        sections = []

        let sectionTypes: [ORKConsentSectionType] = [
            // see ORKConsentSectionType.description for CKConfiguration.plist keys
            .overview, // "Overview"
            .dataGathering, // "DataGathering"
            .privacy, // "Privacy"
            .dataUse, // "DataUse"
            .timeCommitment, // "TimeCommitment"
            .studySurvey, // "StudySurvey"
            .studyTasks, // "StudyTasks"
            .withdrawing // "Withdrawing"
        ]

        guard let consentForm = config.readAny(query: "Consent Form") as? [String: [String: String]] else {
            return
        }

        for type in sectionTypes {
            let section = ORKConsentSection(type: type)

            if let consentSection = consentForm[type.description] {
                let errorMessage = "We didn't find a consent form for your project. Did you configure the CKConfiguration.plist file already?"
                section.title = consentSection["Title"] ?? ":("
                section.summary = consentSection["Summary"] ?? errorMessage
                section.content = consentSection["Content"] ?? errorMessage
                sections?.append(section)
            }
        }

        let signature = ORKConsentSignature(
            forPersonWithTitle: nil,
            dateFormatString: nil,
            identifier: "ConsentDocumentParticipantSignature"
        )
        signature.title = title
        signaturePageTitle = title
        addSignature(signature)
    }

    @available(*, unavailable)
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
