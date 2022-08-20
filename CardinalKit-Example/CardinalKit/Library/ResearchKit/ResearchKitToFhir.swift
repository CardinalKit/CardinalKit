//
//  ResearchKitToFhir.swift
//  CardinalKit
//
//  Created by Vishnu Ravi on 8/11/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit
import ModelsR4

class ResearchKitToFhir {

    private let EMPTY_RESPONSE = "No data"

    /// Extracts results from a ResearchKit survey task and converts to a FHIR QuestionnaireResponse in JSON
    /// - Parameter results: the result of a ResearchKit survey task (ORKTaskResult)
    /// - Returns: a String containing the FHIR QuestionnaireResponse in JSON
    public func extractResultsToFhir(result: ORKTaskResult) -> String {
        var questionnaireResponses = [QuestionnaireResponseItem]()
        if let taskResults = result.results as? [ORKStepResult] {
            for step in taskResults {
                if let stepResults = step.results {
                    for result in stepResults {
                        let response = createResponse(result)
                        if response.answer != nil {
                            questionnaireResponses += [response]
                        }
                    }
                }
            }
        }

        let questionnaireResponse = QuestionnaireResponse(status: FHIRPrimitive(QuestionnaireResponseStatus.completed))
        questionnaireResponse.item = questionnaireResponses

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try! encoder.encode(questionnaireResponse)
        let json = String(data: data, encoding: .utf8)!
        return json
    }


    // Functions for creating FHIR responses from ResearchKit results

    private func createResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        let responseAnswer = QuestionnaireResponseItemAnswer()

        switch(result) {
        case let result as ORKBooleanQuestionResult:
            responseAnswer.value = createBooleanResponse(result)
        case let result as ORKChoiceQuestionResult:
            responseAnswer.value = createChoiceResponse(result)
        case let result as ORKNumericQuestionResult:
            responseAnswer.value = createNumericResponse(result)
        case let result as ORKDateQuestionResult:
            responseAnswer.value = createDateResponse(result)
        case let result as ORKTextQuestionResult:
            responseAnswer.value = createTextResponse(result)
        default:
            // Unsupported result type
            responseAnswer.value = createEmptyResponse()
        }

        response.answer = [responseAnswer]
        return response
    }

    private func createEmptyResponse() -> QuestionnaireResponseItemAnswer.ValueX {
        return .string(FHIRPrimitive(FHIRString(EMPTY_RESPONSE)))
    }

    private func createNumericResponse(_ result: ORKNumericQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        if let value = result.numericAnswer as? Int32 {
            return .integer(FHIRPrimitive(FHIRInteger(value)))
        }
        return nil
    }

    private func createTextResponse(_ result: ORKTextQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        if let text = result.textAnswer {
            return .string(FHIRPrimitive(FHIRString(text)))
        }
        return nil
    }

    private func createChoiceResponse(_ result: ORKChoiceQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        if result.answer != nil {
            if let answerArray = result.answer as? NSArray {
                if answerArray.count > 0 {
                    let answerString = answerArray[0] as? String ?? EMPTY_RESPONSE
                    return .string(FHIRPrimitive(FHIRString(answerString)))
                }
            }
        }
        return nil
    }

    private func createBooleanResponse(_ result: ORKBooleanQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        if let booleanAnswer = result.booleanAnswer {
            let answer = FHIRPrimitive(FHIRBool(booleanAnswer.boolValue))
            return .boolean(answer)
        }
        return nil
    }

    private func createDateResponse(_ result: ORKDateQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        if let dateAnswer = result.dateAnswer {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY/MM/dd"
            let dateString = dateFormatter.string(from: dateAnswer)
            let answer = FHIRPrimitive(try? FHIRDate(dateString))
            return .date(answer)
        }
        return nil
    }
}
