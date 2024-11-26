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
        static let itemControl = "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl"
        static let questionnaireUnit = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
        static let regex = "http://hl7.org/fhir/StructureDefinition/regex"
        static let sliderStepValue = "http://hl7.org/fhir/StructureDefinition/questionnaire-sliderStepValue"
        static let validationMessage = "http://bdh.stanford.edu/fhir/StructureDefinition/validationtext"
        static let validationMessageLegacy = "http://biodesign.stanford.edu/fhir/StructureDefinition/validationtext"
        static let maxDecimalPlaces = "http://hl7.org/fhir/StructureDefinition/maxDecimalPlaces"
        static let minValue = "http://hl7.org/fhir/StructureDefinition/minValue"
        static let maxValue = "http://hl7.org/fhir/StructureDefinition/maxValue"
        static let hidden = "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden"
        static let entryFormat = "http://hl7.org/fhir/StructureDefinition/entryFormat"
        
#if os(iOS) || os(visionOS)
        static let keyboardType = "http://bdh.stanford.edu/fhir/StructureDefinition/ios-keyboardtype"
#endif
#if os(iOS) || os(visionOS) || os(tvOS)
        static let textContentType = "http://bdh.stanford.edu/fhir/StructureDefinition/ios-textcontenttype"
        static let autocapitalizationType = "http://bdh.stanford.edu/fhir/StructureDefinition/ios-autocapitalizationType"
#endif

        static let dateMaxValue = "http://ehelse.no/fhir/StructureDefinition/sdf-maxvalue"
        static let dateMinValue = "http://ehelse.no/fhir/StructureDefinition/sdf-minvalue"

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
        
    /// Defines the control type for the answer for a question
    /// - Returns: A code representing the control type (i.e. slider)
    var itemControl: String? {
        guard let itemControlExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.itemControl),
              case let .codeableConcept(concept) = itemControlExtension.value,
              let itemControlCode = concept.coding?.first?.code?.value?.string else {
            return nil
        }
        return itemControlCode
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

    /// The offset between numbers on a numerical slider
    /// - Returns: An optional `NSNumber` representing the size of each discrete offset on the scale.
    var sliderStepValue: NSNumber? {
        guard let sliderStepValueExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.sliderStepValue),
              case let .integer(integerValue) = sliderStepValueExtension.value,
              let sliderStepValue = integerValue.value?.integer as? Int32 else {
            return nil
        }
        return NSNumber(value: sliderStepValue)
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
        guard let validationMessageExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.validationMessage)
                ?? getExtensionInQuestionnaireItem(url: SupportedExtensions.validationMessageLegacy),
              case let .string(message) = validationMessageExtension.value,
              let stringMessage = message.value?.string else {
            return nil
        }
        return stringMessage
    }
    
    var placeholderText: String? {
        guard let entryFormatExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.entryFormat),
              case let .string(placeholder) = entryFormatExtension.value,
              let placeholderText = placeholder.value?.string else {
            return nil
        }
        return placeholderText
    }
    
#if os(iOS) || os(visionOS)
    var keyboardType: UIKeyboardType? {
        guard let keyboardTypeExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.keyboardType),
              case let .string(keyboardTypeValue) = keyboardTypeExtension.value,
              let keyboardTypeString = keyboardTypeValue.value?.string else {
            return nil
        }

        switch keyboardTypeString {
        case "default":
            return .default
        case "asciiCapable":
            return .asciiCapable
        case "numbersAndPunctuation":
            return .numbersAndPunctuation
        case "URL":
            return .URL
        case "numberPad":
            return .numberPad
        case "phonePad":
            return .phonePad
        case "namePhonePad":
            return .namePhonePad
        case "emailAddress":
            return .emailAddress
        case "decimalPad":
            return .decimalPad
        case "twitter":
            return .twitter
        case "webSearch":
            return .webSearch
        case "asciiCapableNumberPad":
            return .asciiCapableNumberPad
        default:
            return nil
        }
    }
#endif
#if os(iOS) || os(visionOS) || os(tvOS)
    var autocapitalizationType: UITextAutocapitalizationType? {
        guard let autocapitalizationTypeExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.autocapitalizationType),
              case let .string(autocapitalizationTypeValue) = autocapitalizationTypeExtension.value,
              let autocapitalizationTypeString = autocapitalizationTypeValue.value?.string else {
            return nil
        }

        switch autocapitalizationTypeString {
        case "none":
            return UITextAutocapitalizationType.none
        case "words":
            return .words
        case "sentences":
            return .sentences
        case "allCharacters":
            return .allCharacters
        default:
            return nil
        }
    }

    var textContentType: UITextContentType? {
        guard let contentTypeExtension = getExtensionInQuestionnaireItem(url: SupportedExtensions.keyboardType),
              case let .string(contentTypeValue) = contentTypeExtension.value,
              let contentTypeString = contentTypeValue.value?.string else {
            return nil
        }

        switch contentTypeString {
        case "URL":
            return .URL
        case "namePrefix":
            return .namePrefix
        case "name":
            return .name
        case "nameSuffix":
            return .nameSuffix
        case "givenName":
            return .givenName
        case "middleName":
            return .middleName
        case "familyName":
            return .familyName
        case "nickname":
            return .nickname
        case "organizationName":
            return .organizationName
        case "jobTitle":
            return .jobTitle
        case "location":
            return .location
        case "fullStreetAddress":
            return .fullStreetAddress
        case "streetAddressLine1":
            return .streetAddressLine1
        case "streetAddressLine2":
            return .streetAddressLine2
        case "addressCity":
            return .addressCity
        case "addressCityAndState":
            return .addressCityAndState
        case "addressState":
            return .addressState
        case "postalCode":
            return .postalCode
        case "sublocality":
            return .sublocality
        case "countryName":
            return .countryName
        case "username":
            return .username
        case "password":
            return .password
        case "newPassword":
            return .newPassword
        case "oneTimeCode":
            return .oneTimeCode
        case "emailAddress":
            return .emailAddress
        case "telephoneNumber":
            return .telephoneNumber
        case "creditCardNumber":
            return .creditCardNumber
        case "dateTime":
            return .dateTime
        case "flightNumber":
            return .flightNumber
        case "shipmentTrackingNumber":
            return .shipmentTrackingNumber
        default:
            if #available(iOS 17, visionOS 1, tvOS 17, *) {
                switch contentTypeString {
                case "creditCardExpiration":
                    return .creditCardExpiration
                case "creditCardExpirationMonth":
                    return .creditCardExpirationMonth
                case "creditCardExpirationYear":
                    return .creditCardExpirationYear
                case "creditCardSecurityCode":
                    return .creditCardSecurityCode
                case "creditCardType":
                    return .creditCardType
                case "creditCardName":
                    return .creditCardName
                case "creditCardGivenName":
                    return .creditCardGivenName
                case "creditCardMiddleName":
                    return .creditCardMiddleName
                case "creditCardFamilyName":
                    return .creditCardFamilyName
                case "birthdate":
                    return .birthdate
                default:
                    break
                }
            }

            return nil
        }
    }
#endif



    /// Checks this QuestionnaireItem for an extension matching the given URL and then return it if it exists.
    /// - Parameters:
    ///   - url: A `String` identifying the extension.
    /// - Returns: an optional Extension if it was found.
    private func getExtensionInQuestionnaireItem(url: String) -> Extension? {
        self.`extension`?.first(where: { $0.url.value?.url.absoluteString == url })
    }
}

extension FHIRDate {
    /// Converts a `FHIRDate` to a `Date` with the time set to the start of day in the user's current time zone.
    /// If either the month or day are not provided, we will assume they are the first.
    /// - Returns: An optional `Date`
    var asDateAtStartOfDayWithDefaults: Date? {
        let dateComponents = DateComponents(year: year, month: Int(month ?? 1), day: Int(day ?? 1))
        return Calendar.current.date(from: dateComponents).map { Calendar.current.startOfDay(for: $0) }
    }
}
