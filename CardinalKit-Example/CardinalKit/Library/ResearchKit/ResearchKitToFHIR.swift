//
//  ResearchKitToFHIR.swift
//  CardinalKit
//
//  Created by Vishnu Ravi on 8/11/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit
import ModelsR4


extension ORKTaskResult {
    /// Extracts results from a ResearchKit survey task and converts to a FHIR QuestionnaireResponse in JSON
    /// - Parameter results: the result of a ResearchKit survey task (ORKTaskResult)
    /// - Returns: a String containing the FHIR QuestionnaireResponse in JSON
    public var fhirResponses: QuestionnaireResponse {
        var questionnaireResponses: [QuestionnaireResponseItem] = []
        let taskResults = self.results as? [ORKStepResult] ?? []
        let id = self.identifier
        
        for result in taskResults.compactMap(\.results).flatMap({ $0 }) {
            let response = createResponse(result)
            if response.answer != nil {
                questionnaireResponses.append(response)
            }
        }

        let questionnaireResponse = QuestionnaireResponse(status: FHIRPrimitive(QuestionnaireResponseStatus.completed))
        questionnaireResponse.item = questionnaireResponses
        questionnaireResponse.id = FHIRPrimitive(FHIRString(id))
        return questionnaireResponse
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
            responseAnswer.value = nil
        }

        response.answer = [responseAnswer]
        return response
    }

    private func createNumericResponse(_ result: ORKNumericQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let value = result.numericAnswer as? Int32 else {
            return nil
        }
        return .integer(FHIRPrimitive(FHIRInteger(value)))
    }

    private func createTextResponse(_ result: ORKTextQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let text = result.textAnswer else {
            return nil
        }
        return .string(FHIRPrimitive(FHIRString(text)))
    }

    private func createChoiceResponse(_ result: ORKChoiceQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let answerArray = result.answer as? NSArray,
              answerArray.count > 0,
              let answerString = answerArray[0] as? String else {
            return nil
        }
        return .string(FHIRPrimitive(FHIRString(answerString)))
    }

    private func createBooleanResponse(_ result: ORKBooleanQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let booleanAnswer = result.booleanAnswer else {
            return nil
        }
        return .boolean(FHIRPrimitive(FHIRBool(booleanAnswer.boolValue)))
    }

    private func createDateResponse(_ result: ORKDateQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let dateAnswer = result.dateAnswer else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY/MM/dd"
        let dateString = dateFormatter.string(from: dateAnswer)
        let answer = FHIRPrimitive(try? FHIRDate(dateString))
        return .date(answer)
    }
}
