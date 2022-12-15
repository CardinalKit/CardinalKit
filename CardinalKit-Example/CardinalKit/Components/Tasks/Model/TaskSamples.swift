//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit
import ModelsR4


/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
*/
struct TaskSamples {
    
    /**
     Active tasks created with short-hand constructors from `ORKOrderedTask`
    */
    static let sampleTappingTask: ORKOrderedTask = {
        let intendedUseDescription = "Finger tapping is a universal way to communicate."
        
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: "TappingTask", intendedUseDescription: intendedUseDescription, duration: 10, handOptions: .both, options: ORKPredefinedTaskOption())
    }()
    
    static let sampleWalkingTask: ORKOrderedTask = {
        let intendedUseDescription = "Tests ability to walk"
        
        return ORKOrderedTask.shortWalk(withIdentifier: "ShortWalkTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 20, restDuration: 30, options: ORKPredefinedTaskOption())
    }()
    
    /**
        Coffee Task Example for 9/2 Workshop
     */
    static let sampleCoffeeTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Coffee Step
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 0, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "A Lot 😬", minimumValueDescription: "None 😴")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "CoffeeScaleQuestionStep", title: "Coffee Intake", question: "How many cups of coffee do you drink per day?", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you for tracking your coffee."
        summaryStep.text = "We appreciate your caffeinated energy! check out the results chart."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-Coffee", steps: steps)
        
    }()
    
    /**
     Sample task created step-by-step!
    */
    static let sampleSurveyTask: ORKOrderedTask = {
        var steps = [ORKStep]()
        
        // Instruction step
        let instructionStep = ORKInstructionStep(identifier: "IntroStep")
        instructionStep.title = "Patient Questionnaire"
        instructionStep.text = "This information will help your doctors keep track of how you feel and how well you are able to do your usual activities. If you are unsure about how to answer a question, please give the best answer you can and make a written comment beside your answer."
        
        steps += [instructionStep]
        
        //In general, would you say your health is:
        let healthScaleAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 5, minimumValue: 1, defaultValue: 3, step: 1, vertical: false, maximumValueDescription: "Excellent", minimumValueDescription: "Poor")
        let healthScaleQuestionStep = ORKQuestionStep(identifier: "HealthScaleQuestionStep", title: "Question #1", question: "In general, would you say your health is:", answer: healthScaleAnswerFormat)
        
        steps += [healthScaleQuestionStep]
        
        let textChoices = [
            ORKTextChoice(text: "Yes, Limited A lot", value: 0 as NSSecureCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, Limited A Little", value: 1 as NSSecureCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No, Not Limited At All", value: 2 as NSSecureCoding & NSCopying & NSObjectProtocol)
        ]
        let textChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        let textStep = ORKQuestionStep(identifier: "TextStep", title: "Daily Activities", question: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answer: textChoiceAnswerFormat)
        
        steps += [textStep]
        
        
        let formItem = ORKFormItem(identifier: "FormItem1", text: "MODERATE ACTIVITIES, such as moving a table, pushing a vacuum cleaner, bowling, or playing golf:", answerFormat: textChoiceAnswerFormat)
        let formItem2 = ORKFormItem(identifier: "FormItem2", text: "Climbing SEVERAL flights of stairs:", answerFormat: textChoiceAnswerFormat)
        let formStep = ORKFormStep(identifier: "FormStep", title: "Daily Activities", text: "The following two questions are about activities you might do during a typical day. Does YOUR HEALTH NOW LIMIT YOU in these activities? If so, how much?")
        formStep.formItems = [formItem, formItem2]
        
        steps += [formStep]
        
        let booleanAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
        let booleanQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: "In the past four weeks, did you feel limited in the kind of work that you can accomplish?", answer: booleanAnswer)
        
        steps += [booleanQuestionStep]
        
        //SUMMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [summaryStep]
        
        return ORKOrderedTask(identifier: "SurveyTask-Assessment", steps: steps)
    }()
    
    /// An example of FHIR-based ResearchKit tasks using the FHIR to ResearchKit translation functionality.
    static let sampleFHIRTask: ORKOrderedTask = {
        let fhirJSON = """
            {
              "resourceType": "Questionnaire",
              "id": "sample-fhir-questionnaire-cardinalkit",
              "url": "http://cardinalkit.org/fhir/sample-fhir-questionnaire-cardinalkit",
              "language": "en-US",
              "status": "draft",
              "publisher": "CardinalKit",
              "meta": {
                "profile": [
                  "http://cardinalkit.org/fhir/StructureDefinition/sdf-Questionnaire"
                ],
                "tag": [
                  {
                    "system": "urn:ietf:bcp:47",
                    "code": "en-US",
                    "display": "English"
                  }
                ]
              },
              "useContext": [
                {
                  "code": {
                    "system": "http://hl7.org/fhir/ValueSet/usage-context-type",
                    "code": "focus",
                    "display": "Clinical Focus"
                  },
                  "valueCodeableConcept": {
                    "coding": [
                      {
                        "system": "urn:oid:2.16.578.1.12.4.1.1.8655"
                      }
                    ]
                  }
                }
              ],
              "contact": [
                {
                  "name": "http://cardinalkit.org"
                }
              ],
              "subjectType": [
                "Patient"
              ],
              "item": [
                {
                  "linkId": "f0f95365-96d2-4892-9ccf-2e2c0c74a87c",
                  "type": "boolean",
                  "text": "Do you like ice cream?",
                  "required": true
                },
                {
                  "linkId": "169e7113-1e8f-4858-fc97-5703ba865703",
                  "type": "group",
                  "text": "What is your favorite type?",
                  "item": [
                    {
                      "linkId": "59e7a3f7-4108-47a7-8fae-0fb892574a63",
                      "type": "choice",
                      "text": "What is your favorite flavor?",
                      "required": false,
                      "answerOption": [
                        {
                          "valueCoding": {
                            "id": "460afea8-2634-4bb4-89d2-001d92624d6c",
                            "code": "chocolate",
                            "system": "urn:uuid:ea53f9f1-4c06-4953-83b6-c944bccdeae3",
                            "display": "Chocolate"
                          }
                        },
                        {
                          "valueCoding": {
                            "id": "6fef1216-0b74-40bd-e773-2bd4a7f66e45",
                            "code": "vanilla",
                            "system": "urn:uuid:ea53f9f1-4c06-4953-83b6-c944bccdeae3",
                            "display": "Vanilla"
                          }
                        },
                        {
                          "valueCoding": {
                            "id": "abc0a0bf-0e35-48db-8f0f-b2d30038816b",
                            "code": "strawberry",
                            "system": "urn:uuid:ea53f9f1-4c06-4953-83b6-c944bccdeae3",
                            "display": "Strawberry"
                          }
                        },
                        {
                          "valueCoding": {
                            "id": "d1c27eeb-022a-4ef9-8f70-068d96a26154",
                            "code": "other",
                            "system": "urn:uuid:ea53f9f1-4c06-4953-83b6-c944bccdeae3",
                            "display": "Other"
                          }
                        }
                      ]
                    }
                  ],
                  "required": false,
                  "enableWhen": [
                    {
                      "question": "f0f95365-96d2-4892-9ccf-2e2c0c74a87c",
                      "operator": "=",
                      "answerBoolean": true
                    }
                  ]
                },
              ]
            }
            """
        
        do {
            let questionaire = try JSONDecoder().decode(Questionnaire.self, from: Data(fhirJSON.utf8))
            return try ORKNavigableOrderedTask(questionnaire: questionaire)
        } catch let error as FHIRToResearchKitConversionError {
            fatalError("Failed to parse the example FHIR task due to a conversion error: \(error)")
        } catch {
            fatalError("Failed to parse the example FHIR task: \(error)")
        }
    }()
}
