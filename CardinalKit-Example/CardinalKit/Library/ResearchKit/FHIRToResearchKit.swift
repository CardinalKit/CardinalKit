//
//  FHIRToResearchKit.swift
//  CardinalKit
//
//  Created by Vishnu Ravi on 6/21/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ModelsR4
import ResearchKit


public enum FHIRToResearchKitConversionError: Error, CustomStringConvertible {
    case noItems
    case unsupportedOperator(QuestionnaireItemOperator)
    case unsupportedAnswer(QuestionnaireItemEnableWhen.AnswerX)
    case noOptions
    case invalidDate(FHIRPrimitive<FHIRDate>)
    
    
    public var description: String {
        switch self {
        case .noItems:
            return "The parsed FHIR Questionaire didn't contain any items"
        case let .unsupportedOperator(fhirOperator):
            return "An unsupported operator was used: \(fhirOperator)"
        case let .unsupportedAnswer(answer):
            return "An unsupported answer type was used: \(answer)"
        case .noOptions:
            return "No Option was provided."
        case let .invalidDate(date):
            return "Encountered an invalid date when parsing the questionaire: \(date)"
        }
    }
}


/// A class that converts FHIR Questionnaires to ResearchKit ORKOrderedTasks
extension ORKNavigableOrderedTask {
    /// Supported FHIR extensions
    private enum SupportedExtensions {
        static let questionaireUnit = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
        static let regex = "http://hl7.org/fhir/StructureDefinition/regex"
    }
    
    
    public convenience init(
        identifier: String,
        title: String,
        questionnaire: Questionnaire,
        summaryStep: ORKCompletionStep? = nil
    ) throws {
        guard let item = questionnaire.item else {
            throw FHIRToResearchKitConversionError.noItems
        }
        
        // Convert each FHIR Questionnaire Item to an ORKStep
        var steps = ORKNavigableOrderedTask.fhirQuestionnaireItemsToORKSteps(items: item, title: title)
        
        // Add a summary step at the end of the task if defined
        if let summaryStep = summaryStep {
            steps.append(summaryStep)
        }

        self.init(identifier: identifier, steps: steps)
        // If any questions have defined skip logic, convert to ResearchKit navigation rules
        try constructNavigationRules(questions: item)
    }
    

    /// Converts FHIR QuestionnaireItems (questions) to ResearchKit ORKSteps
    /// - Parameters:
    ///   - questions: an array of FHIR QuestionnaireItems
    ///   - title: a String that will be rendered above the questions by ResearchKit
    /// - Returns: an array of ResearchKit ORKSteps
    private static func fhirQuestionnaireItemsToORKSteps(items: [QuestionnaireItem], title: String) -> [ORKStep] {
        var surveySteps: [ORKStep] = []
        surveySteps.reserveCapacity(items.count)
        
        for question in items {
            guard let questionType = question.type.value else {
                continue
            }
            
            switch(questionType){
            case QuestionnaireItemType.group:
                // multiple questions in a group
                if let groupStep = fhirGroupToORKFormStep(question: question, title: title) {
                    surveySteps.append(groupStep)
                }
            case QuestionnaireItemType.display:
                // a string to display that does not take an answer
                if let instructionStep = fhirDisplayToORKInstructionStep(question: question, title: title) {
                    surveySteps.append(instructionStep)
                }
            default:
                // individual questions
                if let step = fhirQuestionnaireItemToORKQuestionStep(question: question, title: title) {
                    if let required = question.required?.value?.bool {
                        step.isOptional = !required
                    }
                    surveySteps.append(step)
                }
            }
        }
        
        return surveySteps
    }

    /// Converts a FHIR QuestionnaireItem to a ResearchKit ORKQuestionStep
    /// - Parameters:
    ///   - question: a FHIR QuestionnaireItem object (a single question or a set of questions in a group)
    ///   - title: a String that will be displayed above the question when rendered by ResearchKit
    /// - Returns: an ORKQuestionStep object (a ResearchKit question step containing the above question)
    private static func fhirQuestionnaireItemToORKQuestionStep(question: QuestionnaireItem, title: String) -> ORKQuestionStep? {
        guard let questionText = question.text?.value?.string,
              let identifier = question.linkId.value?.string else {
            return nil
        }

        let answer = try? fhirQuestionnaireItemToORKAnswerFormat(question: question)
        return ORKQuestionStep(identifier: identifier, title: title, question: questionText, answer: answer)
    }

    /// Converts a FHIR QuestionnaireItem that contains a group of question items into a ResearchKit form (ORKFormStep)
    /// - Parameters:
    ///   - question: a FHIR QuestionnaireItem object which contains a group of nested questions
    ///   - title: a String that will be displayed at the top of the form when rendered by ResearchKit
    /// - Returns: an ORKFormStep object (a ResearchKit form step containing all of the nested questions)
    private static func fhirGroupToORKFormStep(question: QuestionnaireItem, title: String) -> ORKFormStep? {
        guard let id = question.linkId.value?.string,
              let nestedQuestions = question.item else {
            return nil
        }

        let formStep = ORKFormStep(identifier: id)
        formStep.title = title
        var formItems = [ORKFormItem]()

        for question in nestedQuestions {
            guard let questionId = question.linkId.value?.string,
                  let questionText = question.text?.value?.string,
                  let answerFormat = try? fhirQuestionnaireItemToORKAnswerFormat(question: question) else {
                continue
            }
            
            let formItem = ORKFormItem(identifier: questionId, text: questionText, answerFormat: answerFormat)
            if let required = question.required?.value?.bool {
                formItem.isOptional = required
            }
            
            formItems.append(formItem)
        }

        formStep.formItems = formItems
        return formStep
    }

    /// Converts FHIR QuestionnaireItem display type to ORKInstructionStep
    /// - Parameters:
    ///   - question: a FHIR QuestionnaireItem object
    ///   - title: a String to display at the top of the view rendered by ResearchKit
    /// - Returns: a ResearchKit ORKInstructionStep
    private static func fhirDisplayToORKInstructionStep(question: QuestionnaireItem, title: String) -> ORKInstructionStep? {
        guard let id = question.linkId.value?.string,
              let text = question.text?.value?.string else {
            return nil
        }

        let instructionStep = ORKInstructionStep(identifier: id)
        instructionStep.title = title
        instructionStep.detailText = text
        return instructionStep
    }

    /// Converts FHIR QuestionnaireItem answer types to the corresponding ResearchKit answer types (ORKAnswerFormat)
    /// - Parameter question: a FHIR QuestionnaireItem object
    /// - Returns: an object of type ORKAnswerFormat representing the type of answer this question accepts
    private static func fhirQuestionnaireItemToORKAnswerFormat(question: QuestionnaireItem) throws -> ORKAnswerFormat {
        switch(question.type.value) {
        case .boolean:
            return ORKBooleanAnswerFormat.booleanAnswerFormat()
        case .choice:
            let answerOptions = fhirChoicesToORKTextChoice(question)
            if answerOptions.count > 0 {
                return ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: answerOptions)
            } else {
                throw FHIRToResearchKitConversionError.noOptions
            }
        case .date:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.date)
        case .decimal:
            return ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: "")
        case .integer:
            return ORKNumericAnswerFormat.integerAnswerFormat(withUnit: "")
        case .quantity: // a numeric answer with an included unit to be displayed
            return ORKNumericAnswerFormat.decimalAnswerFormat(withUnit: getUnit(question))
        case .text, .string:
            let validationRegularExpression = getValidationRegularExpression(question)
            let maximumLength = Int(question.maxLength?.value?.integer ?? 0)

            let answerFormat = ORKTextAnswerFormat(maximumLength: maximumLength)
            answerFormat.validationRegularExpression = validationRegularExpression
            return answerFormat
        case .time:
            return ORKDateAnswerFormat(style: ORKDateAnswerStyle.dateAndTime)
        default:
            return ORKTextAnswerFormat()
        }
    }

    /// Converts FHIR text answer choices to ResearchKit ORKTextChoice
    /// - Parameter question: a FHIR QuestionnaireItem
    /// - Returns: an array of ORKTextChoice objects, each representing a textual answer option
    private static func fhirChoicesToORKTextChoice(_ question: QuestionnaireItem) -> [ORKTextChoice] {
        var choices: [ORKTextChoice] = []
        guard let answerOptions = question.answerOption else {
            return choices
        }
        
        for option in answerOptions {
            guard case let .coding(coding) = option.value,
                  let display = coding.display?.value?.string,
                  let code = coding.code?.value?.string else {
                continue
            }
            
            choices.append(ORKTextChoice(text: display, value: code as NSCoding & NSCopying & NSObjectProtocol))
        }
        
        return choices
    }
    
    
    // MARK: FHIR Extensions
    
    /// Gets the unit of a quantity answer type
    /// - Parameter question: a FHIR QuestionnaireItem with a quantity answer type
    /// - Returns: an optional String containing the unit (i.e. cm) if it was provided
    private static func getUnit(_ question: QuestionnaireItem) -> String? {
        guard let unitExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.questionaireUnit),
              case let .coding(coding) = unitExtension.value else {
            return nil
        }
        return coding.code?.value?.string
    }

    /// Checks a QuestionnaireItem for an extension matching the given URL and then return it if it exists
    /// - Parameters:
    ///   - question: a FHIR QuestionnaireItem
    ///   - url: a String identifying the extension
    /// - Returns: an optional Extension if it was found
    private static func getExtensionInQuestionnaireItem(question: QuestionnaireItem, url: String) -> Extension? {
        return question.`extension`?.filter({ $0.url.value?.url.absoluteString == url }).first
    }

    /// Gets the regular expression specified for validating a text input in a question
    /// - Parameter question: a FHIRQuestionnaireItem with a text or string input that contains a regular expression for validation
    /// - Returns: an optional String containing the regular expression, if it exists
    private static func getValidationRegularExpression(_ question: QuestionnaireItem) -> NSRegularExpression? {
        guard let regexExtension = getExtensionInQuestionnaireItem(question: question, url: SupportedExtensions.regex),
              case let .string(regex) = regexExtension.value,
              let stringRegularExpression = regex.value?.string else {
            return nil
        }
        return try? NSRegularExpression(pattern: stringRegularExpression)
    }

    // MARK: Navigation Rules
    
    /**
     This method converts predicates contained in the  "enableWhen" property on FHIR QuestionnaireItem to ResearchKit ORKPredicateSkipStepNavigationRule which are applied to an ORKNavigableOrderedTask.
     - Parameters:
        - questions: an array of FHIR QuestionnaireItem objects
     */
    fileprivate func constructNavigationRules(questions: [QuestionnaireItem]) throws {
        for question in questions {
            guard let questionId = question.linkId.value?.string,
                  let enableWhen = question.enableWhen else {
                continue
            }
            
            for fhirPredicate in enableWhen {
                guard let enableQuestionId = fhirPredicate.question.value?.string,
                      let fhirOperator = fhirPredicate.`operator`.value else {
                    continue
                }
                
                let resultSelector = ORKResultSelector(resultIdentifier: enableQuestionId)
                var predicate: NSPredicate

                // The translation from FHIR to ResearchKit preedicates requires negating the FHIR preedicates as FHIR preedicates activate steps while ResearchKit uses them to skip steps
                switch fhirPredicate.answer {
                case .coding(let coding):
                    guard let matchValue = coding.code?.value?.string else {
                        continue
                    }
                    
                    switch fhirOperator {
                    case .exists, .equal:
                        let matchingPattern = "^(?!\(matchValue)).*$"
                        predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, matchingPattern: matchingPattern)
                    default:
                        throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
                    }
                case .boolean(let boolean):
                    guard let booleanValue = boolean.value?.bool else {
                        continue
                    }
                    
                    switch fhirOperator {
                    case .equal:
                        predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
                            with: resultSelector,
                            expectedAnswer: !booleanValue
                        )
                    case .notEqual:
                        predicate = ORKResultPredicate.predicateForBooleanQuestionResult(
                            with: resultSelector,
                            expectedAnswer: booleanValue
                        )
                    default:
                        throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
                    }
                case .date(let fhirDate):
                    do {
                        let date = try fhirDate.value?.asNSDate() as? Date
                        switch fhirOperator {
                        case .greaterThan:
                            predicate = ORKResultPredicate.predicateForDateQuestionResult(
                                with: resultSelector,
                                minimumExpectedAnswer: nil,
                                maximumExpectedAnswer: date
                            )
                        case .lessThan:
                            predicate = ORKResultPredicate.predicateForDateQuestionResult(
                                with: resultSelector,
                                minimumExpectedAnswer: date,
                                maximumExpectedAnswer: nil
                            )
                        default:
                            throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
                        }
                    } catch {
                        throw FHIRToResearchKitConversionError.invalidDate(fhirDate)
                    }
                case .integer(let integerValue):
                    guard let integerValue = integerValue.value?.integer else {
                        continue
                    }
                    switch fhirOperator {
                    case .equal:
                        predicate = NSCompoundPredicate(
                            notPredicateWithSubpredicate: ORKResultPredicate.predicateForNumericQuestionResult(
                                with: resultSelector,
                                expectedAnswer: Int(integerValue)
                            )
                        )
                    case .notEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            expectedAnswer: Int(integerValue)
                        )
                    case .lessThanOrEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            minimumExpectedAnswerValue: Double(integerValue).nextUp
                        )
                    case .greaterThanOrEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            maximumExpectedAnswerValue: Double(integerValue).nextDown
                        )
                    default:
                        throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
                    }
                case .decimal(let decimalValue):
                    guard let decimalValue = decimalValue.value?.decimal else {
                        continue
                    }
                    switch fhirOperator {
                    case .equal:
                        predicate = NSCompoundPredicate(
                            notPredicateWithSubpredicate: ORKResultPredicate.predicateForNumericQuestionResult(
                                with: resultSelector,
                                minimumExpectedAnswerValue: decimalValue.doubleValue,
                                maximumExpectedAnswerValue: decimalValue.doubleValue
                            )
                        )
                    case .notEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            minimumExpectedAnswerValue: decimalValue.doubleValue,
                            maximumExpectedAnswerValue: decimalValue.doubleValue
                        )
                    case .lessThanOrEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            minimumExpectedAnswerValue: decimalValue.doubleValue.nextUp
                        )
                    case .greaterThanOrEqual:
                        predicate = ORKResultPredicate.predicateForNumericQuestionResult(
                            with: resultSelector,
                            maximumExpectedAnswerValue: decimalValue.doubleValue.nextDown
                        )
                    default:
                        throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
                    }
                default:
                    throw FHIRToResearchKitConversionError.unsupportedAnswer(fhirPredicate.answer)
                }
                
                self.setSkip(ORKPredicateSkipStepNavigationRule(resultPredicate: predicate), forStepIdentifier: questionId)
            }
        }
    }
}


extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
