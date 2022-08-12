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
                    "language": "nb-NO",
                    "status": "draft",
                    "publisher": "NHN",
                    "meta": {
                      "profile": [
                        "http://ehelse.no/fhir/StructureDefinition/sdf-Questionnaire"
                      ],
                      "tag": [
                        {
                          "system": "urn:ietf:bcp:47",
                          "code": "nb-NO",
                          "display": "Norsk Bokmål"
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
                        "name": "http://www.nhn.no"
                      }
                    ],
                    "subjectType": [
                      "Patient"
                    ],
                    "extension": [
                      {
                        "url": "http://helsenorge.no/fhir/StructureDefinition/sdf-sidebar",
                        "valueCoding": {
                          "system": "http://helsenorge.no/fhir/ValueSet/sdf-sidebar",
                          "code": "1"
                        }
                      },
                      {
                        "url": "http://helsenorge.no/fhir/StructureDefinition/sdf-information-message",
                        "valueCoding": {
                          "system": "http://helsenorge.no/fhir/ValueSet/sdf-information-message",
                          "code": "1"
                        }
                      }
                    ],
                    "item": [
                      {
                        "linkId": "061281f3-7fe8-400b-8eee-3b7efdc94abc",
                        "type": "choice",
                        "text": "What is your favourite ice cream?",
                        "required": false,
                        "answerOption": [
                          {
                            "valueCoding": {
                              "id": "3f293818-18a8-41b4-83f8-118e5f92dff1",
                              "code": "chocolate",
                              "system": "urn:uuid:c8dc9534-345f-4f22-ba02-630188c292b2",
                              "display": "Chocolate"
                            }
                          },
                          {
                            "valueCoding": {
                              "id": "88f73723-24e3-4bd4-f85c-df66d99f03d6",
                              "code": "vanilla",
                              "system": "urn:uuid:c8dc9534-345f-4f22-ba02-630188c292b2",
                              "display": "Vanilla"
                            }
                          }
                        ]
                      },
                      {
                        "linkId": "9ae117a1-2f0c-477f-8dfc-d69d8e7ee691",
                        "type": "choice",
                        "text": "What is your favorite candy?",
                        "required": false,
                        "answerOption": [
                          {
                            "valueCoding": {
                              "id": "2e965935-8185-4f05-9bef-2295b39eeb12",
                              "code": "snickers",
                              "system": "urn:uuid:1a041cef-ce74-4501-9439-b06d9f948841",
                              "display": "Snickers"
                            }
                          },
                          {
                            "valueCoding": {
                              "id": "f6265d3c-64b0-4cbc-83f1-f5102c488b6d",
                              "code": "cadbury",
                              "system": "urn:uuid:1a041cef-ce74-4501-9439-b06d9f948841",
                              "display": "Cadbury"
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
