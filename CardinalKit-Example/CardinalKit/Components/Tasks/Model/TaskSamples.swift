//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

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
            ORKTextChoice(text: "Yes, Limited A lot", value: 0 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Yes, Limited A Little", value: 1 as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "No, Not Limited At All", value: 2 as NSCoding & NSCopying & NSObjectProtocol)
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

    static let sampleFHIRTask: ORKOrderedTask = {
        let fhir = """
                  {
                    "resourceType": "Questionnaire",
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
                        "linkId": "65963d48-48a7-4fdc-b52c-1a59dffbd513",
                        "type": "choice",
                        "text": "Do you like ice cream?",
                        "required": false,
                        "answerOption": [
                          {
                            "valueCoding": {
                              "id": "c899e509-cfc6-473e-898d-5b38a60e442e",
                              "code": "yes",
                              "system": "urn:uuid:6fcb8b09-b45e-4acf-fb95-caf0bbf573ed",
                              "display": "Yes"
                            }
                          },
                          {
                            "valueCoding": {
                              "id": "3413a448-dacc-4aff-99ef-a5f0d40888da",
                              "code": "no",
                              "system": "urn:uuid:6fcb8b09-b45e-4acf-fb95-caf0bbf573ed",
                              "display": "No"
                            }
                          }
                        ]
                      },
                      {
                        "linkId": "2664d995-d565-4008-8f28-dea3850a0716",
                        "type": "choice",
                        "text": "What kind of ice cream is your favorite?",
                        "required": false,
                        "answerOption": [
                          {
                            "valueCoding": {
                              "id": "91b9d310-82de-45da-8bfa-4d78b6e4e29d",
                              "code": "chocolate",
                              "system": "urn:uuid:2209cbf6-e620-4c84-890d-bf45dbe4a809",
                              "display": "Chocolate"
                            }
                          },
                          {
                            "valueCoding": {
                              "id": "2a7a8fc5-b252-4830-8907-f90e93fe37a3",
                              "code": "vanilla",
                              "system": "urn:uuid:2209cbf6-e620-4c84-890d-bf45dbe4a809",
                              "display": "Vanilla"
                            }
                          }
                        ],
                        "enableWhen": [
                          {
                            "question": "65963d48-48a7-4fdc-b52c-1a59dffbd513",
                            "operator": "=",
                            "answerCoding": {
                              "system": "urn:uuid:6fcb8b09-b45e-4acf-fb95-caf0bbf573ed",
                              "code": "yes"
                            }
                          }
                        ]
                      }
                    ]
                  }
            """
        let fhirConverter = FhirToResearchKit()
        return fhirConverter.convertFhirQuestionnaireToORKOrderedTask(identifier: "FhirSurvey", json: fhir, title: "FHIR Survey")
    }()
}
