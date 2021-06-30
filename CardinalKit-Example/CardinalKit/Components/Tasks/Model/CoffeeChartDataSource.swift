//
//  CoffeeChartDataSource.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

class CoffeeChartDataSource: NSObject, ORKPieChartViewDataSource {
    
    var countPerAnswer = [NSNumber: CGFloat]()
    var keys = [NSNumber]()
    
    init(countPerAnswer: [NSNumber: CGFloat]) {
        self.countPerAnswer = countPerAnswer
        self.keys = Array(countPerAnswer.keys)
        
        super.init()
    }
    
    func numberOfSegments(in pieChartView: ORKPieChartView) -> Int {
        return keys.count
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
        let key = keys[index]
        return countPerAnswer[key] ?? 0.0
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, titleForSegmentAt index: Int) -> String? {
        let answer = keys[index]
        return "☕️ \(answer)"
    }
    
}

extension CoffeeChartDataSource {
    
    static func fetchData(onCompletion: @escaping ([NSNumber: CGFloat]) -> Void) {
        var countPerAnswer = [NSNumber: CGFloat]()
        
        CKSendHelper.getFromFirestore(collection: Constants.dataBucketSurveys, identifier: "SurveyTask-Coffee") { (document, error) in
            
            guard let payload = document?.data()?["results"] as? [[AnyHashable: Any]] else {
                onCompletion([NSNumber: CGFloat]())
                return
            }
            
            //do {
            for item in payload {
                // let result = try ORKESerializer.object(fromJSONObject: item) as? ORKTaskResult
                //let coffeScale = result?.stepResult(forStepIdentifier: "CoffeeScaleQuestionStep")?.results?.first as? ORKScaleQuestionResult
                let result = CK_ORKSerialization.TaskResult(fromJSONObject: item)
                let coffeScale = result.stepResult(forStepIdentifier: "CoffeeScaleQuestionStep")?.results?.first as? ORKScaleQuestionResult
                if let answer = coffeScale?.scaleAnswer {
                    countPerAnswer[answer] = (countPerAnswer[answer] ?? 0.0) + 1.0
                }
            }
            onCompletion(countPerAnswer)
            /*} catch {
                print("[CoffeeChartDataSource] ERROR " + error.localizedDescription)
               onCompletion([NSNumber: CGFloat]())
            }*/
        }
    }
    
}
