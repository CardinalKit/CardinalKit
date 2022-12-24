//
//  FHIRToResearchKitConversionError.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import ModelsR4


/// An error that is thrown when translating a FHIR `Questionnaire` to an `ORKNavigableOrderedTask`
public enum FHIRToResearchKitConversionError: Error, CustomStringConvertible, Equatable {
    case noItems
    case noURL
    case unsupportedOperator(QuestionnaireItemOperator)
    case unsupportedAnswer(QuestionnaireItemEnableWhen.AnswerX)
    case noOptions
    case invalidDate(FHIRPrimitive<FHIRDate>)

    public var description: String {
        switch self {
        case .noItems:
            return "The parsed FHIR Questionnaire didn't contain any items"
        case .noURL:
            return "This FHIR Questionnaire does not have a URL"
        case let .unsupportedOperator(fhirOperator):
            return "An unsupported operator was used: \(fhirOperator)"
        case let .unsupportedAnswer(answer):
            return "An unsupported answer type was used: \(answer)"
        case .noOptions:
            return "No Option was provided."
        case let .invalidDate(date):
            return "Encountered an invalid date when parsing the questionnaire: \(date)"
        }
    }
}
