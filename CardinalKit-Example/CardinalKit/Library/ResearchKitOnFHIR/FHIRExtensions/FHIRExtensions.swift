//
//  FHIRExtensions.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/15/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import Foundation
import ModelsR4

extension QuestionnaireItem {
    /// Supported FHIR extensions for QuestionnaireItems
    private enum SupportedExtensions {
        static let questionnaireUnit = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
        static let regex = "http://hl7.org/fhir/StructureDefinition/regex"
        static let validationMessage = "http://cardinalkit.org/fhir/StructureDefinition/validationtext"
        static let maxDecimalPlaces = "http://hl7.org/fhir/StructureDefinition/maxDecimalPlaces"
        static let minValue = "http://hl7.org/fhir/StructureDefinition/minValue"
        static let maxValue = "http://hl7.org/fhir/StructureDefinition/maxValue"
        static let hidden = "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden"
    }


    /// Is the question hidden
    /// - Returns: A boolean representing whether the question should be shown to the user
    var hidden: Bool {
        guard let hiddenExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.hidden),
              case let .boolean(booleanValue) = hiddenExtension.value,
              let isHidden = booleanValue.value?.bool as? Bool else {
            return false
        }
        return isHidden
    }

    /// The minimum value for a numerical answer.
    /// - Returns: An optional `NSNumber` containing the minimum value allowed.
    var minValue: NSNumber? {
        guard let minValueExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.minValue),
              case let .integer(integerValue) = minValueExtension.value,
              let minValue = integerValue.value?.integer as? Int32 else {
            return nil
        }
        return NSNumber(value: minValue)
    }

    /// The maximum value for a numerical answer.
    /// - Returns: An optional `NSNumber` containing the maximum value allowed.
    var maxValue: NSNumber? {
        guard let maxValueExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.maxValue),
              case let .integer(integerValue) = maxValueExtension.value,
              let maxValue = integerValue.value?.integer as? Int32 else {
            return nil
        }
        return NSNumber(value: maxValue)
    }

    /// The maximum number of decimal places for a decimal answer.
    /// - Returns: An optional `NSNumber` representing the maximum number of digits to the right of the decimal place.
    var maximumDecimalPlaces: NSNumber? {
        guard let maxDecimalPlacesExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.maxDecimalPlaces),
              case let .integer(integerValue) = maxDecimalPlacesExtension.value,
              let maxDecimalPlaces = integerValue.value?.integer as? Int32 else {
                return nil
        }
        return NSNumber(value: maxDecimalPlaces)
    }

    /// The unit of a quantity answer type.
    /// - Returns: An optional `String` containing the unit (i.e. cm) if it was provided.
    var unit: String? {
        guard let unitExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.questionnaireUnit),
              case let .coding(coding) = unitExtension.value else {
            return nil
        }
        return coding.code?.value?.string
    }

    /// The regular expression specified for validating a text input in a question.
    /// - Returns: An optional `String` containing the regular expression, if it exists.
    var validationRegularExpression: NSRegularExpression? {
        guard let regexExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.regex),
              case let .string(regex) = regexExtension.value,
              let stringRegularExpression = regex.value?.string else {
            return nil
        }
        return try? NSRegularExpression(pattern: stringRegularExpression)
    }

    /// The validation message for a question.
    /// - Returns: An optional `String` containing the validation message, if it exists.
    var validationMessage: String? {
        guard let validationMessageExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.validationMessage),
              case let .string(message) = validationMessageExtension.value,
              let stringMessage = message.value?.string else {
            return nil
        }
        return stringMessage
    }


    /// Checks this QuestionnaireItem for an extension matching the given URL and then return it if it exists.
    /// - Parameters:
    ///   - url: A `String` identifying the extension.
    /// - Returns: an optional Extension if it was found.
    private func getExtensionInQuestionnaireItem(url: String) -> Extension? {
        self.`extension`?.first(where: { $0.url.value?.url.absoluteString == url })
    }
}
