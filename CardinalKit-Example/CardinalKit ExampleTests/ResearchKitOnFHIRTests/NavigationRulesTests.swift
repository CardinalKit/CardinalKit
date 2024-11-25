//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ModelsR4
import ResearchKit
import XCTest


final class NavigationRulesTests: XCTestCase {
    private func createORKNavigableOrderedTask(
        firstItemID: String,
        firstItemType: QuestionnaireItemType,
        secondItemID: String,
        secondItemType: QuestionnaireItemType,
        enableWhen: QuestionnaireItemEnableWhen
    ) throws -> ORKNavigableOrderedTask {
        let questionnaire = Questionnaire(status: FHIRPrimitive(PublicationStatus.draft))
        questionnaire.url = FHIRPrimitive(FHIRURI(stringLiteral: "http://biodesign.stanford.edu/fhir/questionnaire/navigation-rule-test"))
        let questionnaireItemFirst = QuestionnaireItem(
            linkId: FHIRPrimitive(FHIRString(firstItemID)),
            type: FHIRPrimitive(firstItemType)
        )
        let questionnaireItemSecond = QuestionnaireItem(
            enableWhen: [enableWhen],
            linkId: FHIRPrimitive(FHIRString(secondItemID)),
            type: FHIRPrimitive(secondItemType)
        )
        questionnaire.item = [questionnaireItemFirst, questionnaireItemSecond]
        let orkNavigableOrderedTask = try ORKNavigableOrderedTask(questionnaire: questionnaire)
        return orkNavigableOrderedTask
    }
    
    func testIntegerEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .integer(100),
            operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .integer,
            secondItemID: secondItemID,
            secondItemType: .integer,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testIntegerNotEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .integer(100),
            operator: FHIRPrimitive(QuestionnaireItemOperator.notEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .integer,
            secondItemID: secondItemID,
            secondItemType: .integer,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testIntegerLessThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .integer(100),
            operator: FHIRPrimitive(QuestionnaireItemOperator.lessThanOrEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .integer,
            secondItemID: secondItemID,
            secondItemType: .integer,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testIntegerGreaterThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .integer(100),
            operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThanOrEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .integer,
            secondItemID: secondItemID,
            secondItemType: .integer,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDecimalEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .decimal(100.0),
            operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .decimal,
            secondItemID: secondItemID,
            secondItemType: .decimal,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDecimalNotEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .decimal(100.0),
            operator: FHIRPrimitive(QuestionnaireItemOperator.notEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .decimal,
            secondItemID: secondItemID,
            secondItemType: .decimal,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDecimalGreaterThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .decimal(100.0),
            operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThanOrEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .decimal,
            secondItemID: secondItemID,
            secondItemType: .decimal,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDecimalLessThanOrEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .decimal(100.0),
            operator: FHIRPrimitive(QuestionnaireItemOperator.lessThanOrEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .decimal,
            secondItemID: secondItemID,
            secondItemType: .decimal,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDateLessThan() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .date(FHIRPrimitive(try FHIRDate(date: Date()))),
            operator: FHIRPrimitive(QuestionnaireItemOperator.lessThan),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .date,
            secondItemID: secondItemID,
            secondItemType: .date,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testDateGreaterThan() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .date(FHIRPrimitive(try FHIRDate(date: Date()))),
            operator: FHIRPrimitive(QuestionnaireItemOperator.greaterThan),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .date,
            secondItemID: secondItemID,
            secondItemType: .date,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testCodingEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let coding = Coding(
            code: FHIRPrimitive(FHIRString("testCode")),
            system: FHIRPrimitive(FHIRURI("http://biodesign.stanford.edu/fhir/system/testSystem"))
        )
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .coding(coding),
            operator: FHIRPrimitive(QuestionnaireItemOperator.equal),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .choice,
            secondItemID: secondItemID,
            secondItemType: .choice,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
    
    func testCodingNotEqual() throws {
        let firstItemID = UUID().uuidString, secondItemID = UUID().uuidString
        let coding = Coding(
            code: FHIRPrimitive(FHIRString("testCode")),
            system: FHIRPrimitive(FHIRURI("http://biodesign.stanford.edu/fhir/system/testSystem"))
        )
        let enableWhen = QuestionnaireItemEnableWhen(
            answer: .coding(coding),
            operator: FHIRPrimitive(QuestionnaireItemOperator.notEqual),
            question: FHIRPrimitive(FHIRString(firstItemID))
        )
        let task = try createORKNavigableOrderedTask(
            firstItemID: firstItemID,
            firstItemType: .choice,
            secondItemID: secondItemID,
            secondItemType: .choice,
            enableWhen: enableWhen
        )
        XCTAssertNotNil(task.skipNavigationRule(forStepIdentifier: secondItemID))
    }
}
