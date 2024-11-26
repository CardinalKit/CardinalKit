//
//  NavigationRules.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import ModelsR4
import ResearchKit


extension ORKNavigableOrderedTask {
    /// This method converts predicates contained in the  "enableWhen" property on FHIR `QuestionnaireItem`
    /// to ResearchKit `ORKPredicateSkipStepNavigationRule` which are applied to an `ORKNavigableOrderedTask`.
    /// - Parameters:
    ///    - questions: An array of FHIR QuestionnaireItem objects.
    func constructNavigationRules(questions: [QuestionnaireItem]) throws {
        for question in questions {
            guard let questionId = question.linkId.value?.string,
                  let enableWhen = question.enableWhen,
                  !enableWhen.isEmpty else {
                continue
            }
            
            if enableWhen.count > 1 {
                let enableBehavior = question.enableBehavior?.value ?? .all
                let allPredicates: [NSPredicate] = enableWhen.compactMap {
                    do {
                        return try $0.predicate
                    } catch {
                        print("Error creating predicate: \(error)")
                        return nil
                    }
                }
                
                guard !allPredicates.isEmpty else { continue }
                
                var compoundPredicate = NSCompoundPredicate()
                switch enableBehavior {
                case .all:
                    compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: allPredicates)
                case .any:
                    compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: allPredicates)
                }
                
                self.setSkip(ORKPredicateSkipStepNavigationRule(resultPredicate: compoundPredicate), forStepIdentifier: questionId)
            } else {
                guard let predicate = try enableWhen.first?.predicate else {
                    continue
                }
                self.setSkip(ORKPredicateSkipStepNavigationRule(resultPredicate: predicate), forStepIdentifier: questionId)
            }
        }
    }
}


extension QuestionnaireItemEnableWhen {
    fileprivate var predicate: NSPredicate? {
        get throws {
            guard let enableQuestionId = question.value?.string,
                  let fhirOperator = `operator`.value else {
                return nil
            }

            let resultSelector = ORKResultSelector(resultIdentifier: enableQuestionId)
            let predicate: NSPredicate?

            // The translation from FHIR to ResearchKit predicates requires negating the FHIR predicates as
            // FHIR preedicates activate steps while ResearchKit uses them to skip steps
            switch answer {
            case .coding(let coding):
                predicate = try coding.predicate(with: resultSelector, operator: fhirOperator)
            case .boolean(let boolean):
                predicate = try boolean.predicate(with: resultSelector, operator: fhirOperator)
            case .date(let fhirDate):
                predicate = try fhirDate.predicate(with: resultSelector, operator: fhirOperator)
            case .integer(let integerValue):
                predicate = try integerValue.predicate(with: resultSelector, operator: fhirOperator)
            case .decimal(let decimalValue):
                predicate = try decimalValue.predicate(with: resultSelector, operator: fhirOperator)
            default:
                throw FHIRToResearchKitConversionError.unsupportedAnswer(answer)
            }

            return predicate
        }
    }
}

extension Decimal {
    fileprivate var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Coding {
    fileprivate func predicate(with resultSelector: ORKResultSelector, operator fhirOperator: QuestionnaireItemOperator) throws -> NSPredicate? {
        guard let code = code?.value?.string,
              let system = system?.value?.url.absoluteString else {
            return nil
        }
        
        let expectedAnswer = ValueCoding(code: code, system: system, display: display?.value?.string)
        
        let predicate = ORKResultPredicate.predicateForChoiceQuestionResult(
            with: resultSelector,
            expectedAnswerValue: expectedAnswer.rawValue as NSSecureCoding & NSCopying & NSObjectProtocol
        )
        
        switch fhirOperator {
        case .equal:
            return NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
        case .notEqual:
            return predicate
        default:
            throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
        }
    }
}

extension FHIRPrimitive where PrimitiveType == FHIRBool {
    fileprivate func predicate(
        with resultSelector: ORKResultSelector,
        operator fhirOperator: QuestionnaireItemOperator
    ) throws -> NSPredicate? {
        guard let booleanValue = value?.bool else {
            return nil
        }

        switch fhirOperator {
        case .exists:
            let nilCheckPredicate = ORKResultPredicate.predicateForNilQuestionResult(with: resultSelector)
            return booleanValue ? nilCheckPredicate : NSCompoundPredicate(notPredicateWithSubpredicate: nilCheckPredicate)
        case .equal:
            return ORKResultPredicate.predicateForBooleanQuestionResult(
                with: resultSelector,
                expectedAnswer: !booleanValue
            )
        case .notEqual:
            return ORKResultPredicate.predicateForBooleanQuestionResult(
                with: resultSelector,
                expectedAnswer: booleanValue
            )
        default:
            throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
        }
    }
}

extension FHIRPrimitive where PrimitiveType == FHIRDate {
    fileprivate func predicate(
        with resultSelector: ORKResultSelector,
        operator fhirOperator: QuestionnaireItemOperator
    ) throws -> NSPredicate? {
        do {
            let date = try value?.asNSDate() as? Date
            switch fhirOperator {
            case .greaterThan:
                return ORKResultPredicate.predicateForDateQuestionResult(
                    with: resultSelector,
                    minimumExpectedAnswer: nil,
                    maximumExpectedAnswer: date
                )
            case .lessThan:
                return ORKResultPredicate.predicateForDateQuestionResult(
                    with: resultSelector,
                    minimumExpectedAnswer: date,
                    maximumExpectedAnswer: nil
                )
            default:
                throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
            }
        } catch {
            throw FHIRToResearchKitConversionError.invalidDate(self)
        }
    }
}

extension FHIRPrimitive where PrimitiveType == FHIRInteger {
    fileprivate func predicate(
        with resultSelector: ORKResultSelector,
        operator fhirOperator: QuestionnaireItemOperator
    ) throws -> NSPredicate? {
        guard let integerValue = value?.integer else {
            return nil
        }

        switch fhirOperator {
        case .equal:
            return NSCompoundPredicate(
                notPredicateWithSubpredicate: ORKResultPredicate.predicateForNumericQuestionResult(
                    with: resultSelector,
                    expectedAnswer: Int(integerValue)
                )
            )
        case .notEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                expectedAnswer: Int(integerValue)
            )
        case .lessThanOrEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                minimumExpectedAnswerValue: Double(integerValue).nextUp
            )
        case .greaterThanOrEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                maximumExpectedAnswerValue: Double(integerValue).nextDown
            )
        default:
            throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
        }
    }
}

extension FHIRPrimitive where PrimitiveType == FHIRDecimal {
    fileprivate func predicate(
        with resultSelector: ORKResultSelector,
        operator fhirOperator: QuestionnaireItemOperator
    ) throws -> NSPredicate? {
        guard let decimalValue = value?.decimal else {
            return nil
        }

        switch fhirOperator {
        case .equal:
            return NSCompoundPredicate(
                notPredicateWithSubpredicate: ORKResultPredicate.predicateForNumericQuestionResult(
                    with: resultSelector,
                    minimumExpectedAnswerValue: decimalValue.doubleValue,
                    maximumExpectedAnswerValue: decimalValue.doubleValue
                )
            )
        case .notEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                minimumExpectedAnswerValue: decimalValue.doubleValue,
                maximumExpectedAnswerValue: decimalValue.doubleValue
            )
        case .lessThanOrEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                minimumExpectedAnswerValue: decimalValue.doubleValue.nextUp
            )
        case .greaterThanOrEqual:
            return ORKResultPredicate.predicateForNumericQuestionResult(
                with: resultSelector,
                maximumExpectedAnswerValue: decimalValue.doubleValue.nextDown
            )
        default:
            throw FHIRToResearchKitConversionError.unsupportedOperator(fhirOperator)
        }
    }
}
