//
//  ORKTaskResult+FHIR.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ModelsR4
@_exported import class ModelsR4.QuestionnaireResponse
import ResearchKit
@_exported import class ResearchKit.ORKTaskResult


extension ORKTaskResult {
    /// Extracts results from a ResearchKit survey task and converts to a FHIR `QuestionnaireResponse`.
    public var fhirResponse: QuestionnaireResponse {
        var questionnaireResponses: [QuestionnaireResponseItem] = []
        let taskResults = self.results as? [ORKStepResult] ?? []
        let questionnaireID = self.identifier // a URL representing the questionnaire answered
        let questionnaireResponseID = UUID().uuidString // a unique identifier for this set of answers

        for result in taskResults.compactMap(\.results).flatMap({ $0 }) {
            let response = createResponse(result)
            if response.answer != nil {
                questionnaireResponses.append(response)
            }
        }

        let questionnaireResponse = QuestionnaireResponse(status: FHIRPrimitive(QuestionnaireResponseStatus.completed))
        questionnaireResponse.item = questionnaireResponses
        questionnaireResponse.id = FHIRPrimitive(FHIRString(questionnaireResponseID))
        questionnaireResponse.authored = FHIRPrimitive(try? DateTime(date: Date()))

        if let questionnaireURL = URL(string: questionnaireID) {
            questionnaireResponse.questionnaire = FHIRPrimitive(Canonical(questionnaireURL))
        }

        return questionnaireResponse
    }

    // MARK: Functions for creating FHIR responses from ResearchKit results
    
    private func appendResponseAnswer(_ value: QuestionnaireResponseItemAnswer.ValueX?, to responseAnswers: inout [QuestionnaireResponseItemAnswer]) {
        let responseAnswer = QuestionnaireResponseItemAnswer()
        responseAnswer.value = value
        responseAnswers.append(responseAnswer)
    }

    private func createResponse(_ result: ORKResult) -> QuestionnaireResponseItem {
        let response = QuestionnaireResponseItem(linkId: FHIRPrimitive(FHIRString(result.identifier)))
        var responseAnswers: [QuestionnaireResponseItemAnswer] = []

        switch result {
        case let result as ORKBooleanQuestionResult:
            appendResponseAnswer(createBooleanResponse(result), to: &responseAnswers)
        case let result as ORKChoiceQuestionResult:
            let values = createChoiceResponse(result)
            for value in values {
                appendResponseAnswer(value, to: &responseAnswers)
            }
        case let result as ORKFileResult:
            appendResponseAnswer(createAttachmentResponse(result), to: &responseAnswers)
        case let result as ORKNumericQuestionResult:
            appendResponseAnswer(createNumericResponse(result), to: &responseAnswers)
        case let result as ORKDateQuestionResult:
            appendResponseAnswer(createDateResponse(result), to: &responseAnswers)
        case let result as ORKScaleQuestionResult:
            appendResponseAnswer(createScaleResponse(result), to: &responseAnswers)
        case let result as ORKTimeOfDayQuestionResult:
            appendResponseAnswer(createTimeResponse(result), to: &responseAnswers)
        case let result as ORKTextQuestionResult:
            appendResponseAnswer(createTextResponse(result), to: &responseAnswers)
        default:
            // Unsupported result type
            appendResponseAnswer(nil, to: &responseAnswers)
        }

        response.answer = responseAnswers
        return response
    }

    private func createNumericResponse(_ result: ORKNumericQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let value = result.numericAnswer else {
            return nil
        }

        // If a unit is defined, then the result is a Quantity
        if let unit = result.unit {
            return .quantity(
                Quantity(
                    unit: FHIRPrimitive(FHIRString(unit)),
                    value: FHIRPrimitive(FHIRDecimal(value.decimalValue))
                )
            )
        }

        if result.questionType == ORKQuestionType.integer {
            return .integer(FHIRPrimitive(FHIRInteger(value.int32Value)))
        } else {
            return .decimal(FHIRPrimitive(FHIRDecimal(value.decimalValue)))
        }
    }
    
    private func createScaleResponse(_ result: ORKScaleQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let value = result.scaleAnswer else {
            return nil
        }

        return .integer(FHIRPrimitive(FHIRInteger(value.int32Value)))
    }

    private func createTextResponse(_ result: ORKTextQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let text = result.textAnswer else {
            return nil
        }
        return .string(FHIRPrimitive(FHIRString(text)))
    }

    private func createChoiceResponse(_ result: ORKChoiceQuestionResult) -> [QuestionnaireResponseItemAnswer.ValueX] {
        guard let answerArray = result.answer as? NSArray, answerArray.count > 0 else { // swiftlint:disable:this empty_count
            return []
        }
        
        var responses: [QuestionnaireResponseItemAnswer.ValueX] = []
        
        for answer in answerArray {
            // Check if answer can be treated as a ValueCoding first
            if let valueCodingString = answer as? String, let valueCoding = ValueCoding(rawValue: valueCodingString) {
                let coding = Coding(
                    code: FHIRPrimitive(FHIRString(valueCoding.code)),
                    display: valueCoding.display.map { FHIRPrimitive(FHIRString($0)) },
                    system: FHIRPrimitive(FHIRURI(stringLiteral: valueCoding.system))
                )
                responses += [.coding(coding)]
            } else if let answerString = answer as? String {
                // If not, fall back to treating it as a regular string
                responses += [.string(FHIRPrimitive(FHIRString(answerString)))]
            }
        }
        
        return responses
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

        if result.questionType == .date {
            let fhirDate = try? FHIRDate(date: dateAnswer)
            let answer = FHIRPrimitive(fhirDate)
            return .date(answer)
        } else {
            let fhirDateTime = try? DateTime(date: dateAnswer)
            let answer = FHIRPrimitive(fhirDateTime)
            return .dateTime(answer)
        }
    }

    private func createTimeResponse(_ result: ORKTimeOfDayQuestionResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let timeDateComponents = result.dateComponentsAnswer,
              let hour = UInt8(exactly: timeDateComponents.hour ?? 0),
              let minute = UInt8(exactly: timeDateComponents.minute ?? 0) else {
            return nil
        }

        // Note: ORKTimeOfDayAnswerFormat doesn't support entry of seconds, so it is zero-filled.
        let fhirTime = FHIRPrimitive(FHIRTime(hour: hour, minute: minute, second: 0))
        return .time(fhirTime)
    }
    
    private func createAttachmentResponse(_ result: ORKFileResult) -> QuestionnaireResponseItemAnswer.ValueX? {
        guard let url = result.fileURL else {
            return nil
        }

        return .attachment(Attachment(url: url.asFHIRURIPrimitive()))
    }
}
