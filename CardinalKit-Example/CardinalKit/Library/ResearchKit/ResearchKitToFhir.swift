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

    private let emptyResponse = "No data"

    func extractResultsToFhir(results: ORKTaskViewController) -> String {
        var questionnaireResponses = [QuestionnaireResponseItem]()

        if let taskResults = results.result.results as? [ORKStepResult] {

            for step in taskResults {

                if let stepResults = step.results {

                    for result in stepResults {

                        var response: QuestionnaireResponseItem

                        if let taskStep = results.task?.step?(withIdentifier: step.identifier) {
                            if let taskQuestion = taskStep as? ORKQuestionStep {
                                if let answerFormat = taskQuestion.answerFormat {
                                    switch(answerFormat){
                                    case is ORKTextAnswerFormat:
                                        response = createTextResponse(result)
                                    case is ORKBooleanAnswerFormat:
                                        response = createBooleanResponse(result)
                                    case is ORKTextChoiceAnswerFormat:
                                        response = createChoiceResponse(result)
                                    case is ORKNumericAnswerFormat:
                                        response = createNumericResponse(result)
                                    default:
                                        response = createTextResponse(result)
                                    }

                                    if response.answer != nil {
                                        questionnaireResponses += [response]
                                    }
                                }
                            }
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

    private func createNumericResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        let responseAnswer = QuestionnaireResponseItemAnswer()

        if let result = result as? ORKNumericQuestionResult {
            if let value = result.numericAnswer as? Int32 {
                responseAnswer.value = .integer(FHIRPrimitive(FHIRInteger(value)))
            }
        }

        response.answer = [responseAnswer]
        return response

    }

    private func createTextResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        let responseAnswer = QuestionnaireResponseItemAnswer()

        if let result = result as? ORKTextQuestionResult {
            if let text = result.textAnswer {
                responseAnswer.value = .string(FHIRPrimitive(FHIRString(text)))
            }
        } else {
            responseAnswer.value = .string(FHIRPrimitive(FHIRString(self.emptyResponse)))
        }

        response.answer = [responseAnswer]
        return response
    }

    private func createChoiceResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        let responseAnswer = QuestionnaireResponseItemAnswer()

        if let result = result as? ORKChoiceQuestionResult {
            if result.answer != nil {
                if let answerArray = result.answer as? NSArray {
                    if answerArray.count > 0 {
                        let answerString = answerArray[0] as? String ?? self.emptyResponse
                        responseAnswer.value = .string(FHIRPrimitive(FHIRString(answerString)))
                    }
                }
            }
        }

        response.answer = [responseAnswer]
        return response
    }

    private func createBooleanResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        let responseAnswer = QuestionnaireResponseItemAnswer()

        if let result = result as? ORKBooleanQuestionResult {
            if let booleanAnswer = result.booleanAnswer {
                let answer = FHIRPrimitive(FHIRBool(booleanAnswer.boolValue))
                responseAnswer.value = .boolean(answer)
            }
        }

        response.answer = [responseAnswer]
        return response
    }
}