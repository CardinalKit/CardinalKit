//
// This source file is part of the ResearchKitOnFHIR open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class ModelsR4.Questionnaire


extension Questionnaire {
    // MARK: Example FHIR Questionnaires to demonstrate library functionality
    
    /// A FHIR questionnaire demonstrating enableWhen conditions that are converted to ResearchKit skip logic
    public static var skipLogicExample: Questionnaire = loadQuestionnaire(withName: "SkipLogicExample")
    
    /// A FHIR questionnaire demonstrating multiple enableWhen conditions in an AND / OR configuration
    public static var multipleEnableWhen: Questionnaire = loadQuestionnaire(withName: "MultipleEnableWhen")
    
    /// A FHIR questionnaire demonstrating the use of a regular expression to validate an email address
    public static var textValidationExample: Questionnaire = loadQuestionnaire(withName: "TextValidationExample")
    
    /// A FHIR questionnaire demonstrating the use of a contained ValueSet
    public static var containedValueSetExample: Questionnaire = loadQuestionnaire(withName: "ContainedValueSetExample")
    
    /// A FHIR questionnaire demonstrating integer and decimal inputs
    public static var numberExample: Questionnaire = loadQuestionnaire(withName: "NumberExample")
    
    /// A FHIR questionnaire demonstrating date, dateTime, and time inputs
    public static var dateTimeExample: Questionnaire = loadQuestionnaire(withName: "DateTimeExample")
    
    /// A FHIR questionnaire demonstrating a form with nested questions
    public static var formExample: Questionnaire = loadQuestionnaire(withName: "FormExample")

    /// A FHIR questionnaire demonstrating an image capture step
    public static var imageCaptureExample: Questionnaire = loadQuestionnaire(withName: "ImageCapture")

    /// A FHIR questionnaire demonstrating a slider
    public static var sliderExample: Questionnaire = loadQuestionnaire(withName: "SliderExample")
    
    /// A collection of example `Questionnaire`s provided by the FHIRQuestionnaires target to demonstrate functionality
    public static var exampleQuestionnaires: [Questionnaire] = [
        .skipLogicExample,
        .textValidationExample,
        .containedValueSetExample,
        .numberExample,
        .dateTimeExample,
        .formExample,
        .multipleEnableWhen,
        .imageCaptureExample,
        .sliderExample
    ]
    
    // MARK: Examples of clinical research FHIR Questionnaires
    
    /// The PHQ-9 validated clinical questionnaire
    public static var phq9: Questionnaire = loadQuestionnaire(withName: "PHQ-9")
    
    /// Generalized Anxiety Disorder-7
    public static var gad7: Questionnaire = loadQuestionnaire(withName: "GAD-7")
    
    /// International Prostatism Symptom Score (IPSS)
    public static var ipss: Questionnaire = loadQuestionnaire(withName: "IPSS")
    
    /// The Glasgow Coma Scale
    public static var gcs: Questionnaire = loadQuestionnaire(withName: "GCS")
    
    /// A collection of clinical research `Questionnaire`s
    public static var researchQuestionnaires: [Questionnaire] = [
        .phq9,
        .gad7,
        .ipss,
        .gcs
    ]
    
    
    private static func loadQuestionnaire(withName name: String) -> Questionnaire {
        guard let resourceURL = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Could not find the resource \"\(name)\".json in the Resources folder.")
        }
        
        do {
            let resourceData = try Data(contentsOf: resourceURL)
            return try JSONDecoder().decode(Questionnaire.self, from: resourceData)
        } catch {
            fatalError("Could not decode the FHIR questionnaire named \"\(name).json\": \(error)")
        }
    }
}
