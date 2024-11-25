//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import XCTest


final class ResearchKitToFHIRTests: XCTestCase {
    private func createStepResult(_ result: ORKResult) -> ORKStepResult {
        let stepResult = ORKStepResult(identifier: result.identifier)
        stepResult.results = [result]
        return stepResult
    }
    
    private func createTaskResult(_ result: ORKResult) -> ORKTaskResult {
        let stepResult = createStepResult(result)
        let taskResult = ORKTaskResult(taskIdentifier: result.identifier, taskRun: UUID(), outputDirectory: nil)
        taskResult.results = [stepResult]
        return taskResult
    }
    
    func testTextResponse() {
        let testValue = "test answer"
        var responseValue: String?
        
        let textResult = ORKTextQuestionResult(identifier: "testResult")
        textResult.textAnswer = testValue
        let taskResult = createTaskResult(textResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .string(value) = answer,
           let unwrappedValue = value.value?.string {
            responseValue = unwrappedValue
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testBooleanResponse() {
        let testValue = true
        var responseValue = false
        
        let booleanResult = ORKBooleanQuestionResult(identifier: "booleanResult")
        booleanResult.booleanAnswer = NSNumber(true)
        let taskResult = createTaskResult(booleanResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .boolean(value) = answer,
           let unwrappedValue = value.value?.bool {
            responseValue = unwrappedValue
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testDecimalResponse() {
        let testValue: Decimal = 1.5
        var responseValue: Decimal?
        
        let numericResult = ORKNumericQuestionResult(identifier: "numericResult")
        numericResult.numericAnswer = testValue as NSNumber
        let taskResult = createTaskResult(numericResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .decimal(value) = answer,
           let unwrappedValue = value.value?.decimal {
            responseValue = unwrappedValue
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testIntegerResponse() {
        let testValue = 1
        var responseValue: Int?
        
        let numericResult = ORKNumericQuestionResult(identifier: "numericResult")
        numericResult.numericAnswer = testValue as NSNumber
        numericResult.questionType = ORKQuestionType.integer
        let taskResult = createTaskResult(numericResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .integer(value) = answer,
           let unwrappedValue = value.value?.integer {
            responseValue = Int(unwrappedValue)
        }
        XCTAssertEqual(testValue, responseValue)
    }

    func testScaleResponse() {
        let testValue = 1
        var responseValue: Int?

        let scaleResult = ORKScaleQuestionResult(identifier: "scaleResult")
        scaleResult.scaleAnswer = testValue as NSNumber
        let taskResult = createTaskResult(scaleResult)

        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value

        if case let .integer(value) = answer,
           let unwrappedValue = value.value?.integer {
            responseValue = Int(unwrappedValue)
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testQuantityResponse() {
        let testValue: Decimal = 1.5
        let testUnit = "g"
        var responseValue: Decimal?
        var responseUnit = ""
        
        let numericResult = ORKNumericQuestionResult(identifier: "numericResult")
        numericResult.numericAnswer = testValue as NSNumber
        numericResult.unit = testUnit
        numericResult.questionType = ORKQuestionType.decimal
        let taskResult = createTaskResult(numericResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .quantity(value) = answer,
           let unwrappedValue = value.value?.value?.decimal,
           let unit = value.unit?.value?.string {
            responseValue = unwrappedValue
            responseUnit = unit
        }
        XCTAssertEqual(testValue, responseValue)
        XCTAssertEqual(testUnit, responseUnit)
    }
    
    func testDateTimeResponse() {
        let testValue = Date()
        var responseValue: Date?
        
        let dateResult = ORKDateQuestionResult(identifier: "dateResult")
        dateResult.dateAnswer = testValue
        let taskResult = createTaskResult(dateResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .dateTime(value) = answer,
           let unwrappedValue = try? value.value?.asNSDate() {
            responseValue = unwrappedValue
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testTimeResponse() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let minute = calendar.component(.minute, from: Date())
        let testValue = DateComponents(hour: hour, minute: minute)
        var responseValue = DateComponents()
        
        let timeResult = ORKTimeOfDayQuestionResult(identifier: "timeResult")
        timeResult.dateComponentsAnswer = testValue
        let taskResult = createTaskResult(timeResult)
        
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value
        
        if case let .time(value) = answer,
           let minuteValue = value.value?.minute,
           let hourValue = value.value?.hour {
            responseValue = DateComponents(hour: Int(hourValue), minute: Int(minuteValue))
        }
        XCTAssertEqual(testValue, responseValue)
    }
    
    func testSingleChoiceResponse() {
        let testValue = ValueCoding(code: "testCode", system: "http://biodesign.stanford.edu/test-system", display: "Test Code")
        
        let choiceResult = ORKChoiceQuestionResult(identifier: "choiceResult")
        choiceResult.choiceAnswers = [testValue.rawValue as NSSecureCoding & NSCopying & NSObjectProtocol]
        let taskResult = createTaskResult(choiceResult)
        
        let fhirResponse = taskResult.fhirResponse
        guard let answer = fhirResponse.item?.first?.answer?.first?.value else {
            XCTFail("Could not find the answer in the FHIR response.")
            return
        }
        
        switch answer {
        case let .coding(coding):
            guard let code = coding.code?.value?.string,
                  let display = coding.display?.value?.string,
                  let system = coding.system?.value?.url.absoluteString else {
                XCTFail("Could not extract the code and system from the coding.")
                return
            }
            
            let valueCoding = ValueCoding(code: code, system: system, display: display)
            XCTAssertEqual(testValue, valueCoding)
            
        default:
            XCTFail("Expected a coding value.")
        }
    }

    
    func testMultipleChoiceResponse() {
        let testValues = [
            ValueCoding(code: "testCode1", system: "http://biodesign.stanford.edu/test-system", display: "Test Code 1"),
            ValueCoding(code: "testCode2", system: "http://biodesign.stanford.edu/test-system", display: "Test Code 2")
        ]
        
        let choiceResult = ORKChoiceQuestionResult(identifier: "choiceResult")
        choiceResult.choiceAnswers = testValues.map { $0.rawValue as NSSecureCoding & NSCopying & NSObjectProtocol }
        
        let taskResult = createTaskResult(choiceResult)
        
        let fhirResponse = taskResult.fhirResponse

        guard let firstItem = fhirResponse.item?.first,
              let answers = firstItem.answer?.compactMap({ $0.value }) else {
            XCTFail("Invalid FHIR response.")
            return
        }
        
        guard answers.count == testValues.count else {
            XCTFail("Number of returned answers (\(answers.count)) does not match expected (\(testValues.count)).")
            return
        }

        for (index, answer) in answers.enumerated() {
            switch answer {
            case let .coding(coding):
                guard let code = coding.code?.value?.string,
                      let display = coding.display?.value?.string,
                      let system = coding.system?.value?.url.absoluteString else {
                    XCTFail("Could not extract the code and system from the coding.")
                    return
                }
                
                let valueCoding = ValueCoding(code: code, system: system, display: display)
                XCTAssertEqual(testValues[index], valueCoding)
                
            default:
                XCTFail("Expected a coding value.")
            }
        }
    }

    func testAttachmentResult() {
        let fileResult = ORKFileResult(identifier: "File Result")
        let urlString = "file://images/image.jpg"
        fileResult.fileURL = URL(string: urlString)

        let taskResult = createTaskResult(fileResult)

        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value

        guard case let .attachment(fhirAttachment) = answer else {
            XCTFail("Could not extract attachment file URL.")
            return
        }

        XCTAssertEqual(fhirAttachment.url, urlString.asFHIRURIPrimitive())
    }

    func testORKFileResultWithNoURL() {
        let fileResult = ORKFileResult(identifier: "File Result")
        fileResult.fileURL = nil

        let taskResult = createTaskResult(fileResult)
        let fhirResponse = taskResult.fhirResponse
        let answer = fhirResponse.item?.first?.answer?.first?.value

        XCTAssertNil(answer)
    }
}
