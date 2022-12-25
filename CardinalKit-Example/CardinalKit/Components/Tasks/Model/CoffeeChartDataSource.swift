//
//  CoffeeChartDataSource.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import CardinalKit
import FirebaseFirestore
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
        keys.count
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

        guard let authCollection = CKStudyUser.shared.authCollection else {
           return
        }

        let route = "\(authCollection)\(Constants.dataBucketSurveys)/SurveyTask-Coffee"

        CKApp.requestData(route: route, onCompletion: { result in
           guard let document = result as? DocumentSnapshot,
                 let payload = document.data()?["results"] as? [[AnyHashable: Any]] else {
                onCompletion([NSNumber: CGFloat]())
                 return
             }
            for item in payload {
                let result = CKORKSerialization.taskResult(fromJSONObject: item)
                let coffeeScale = result.stepResult(
                    forStepIdentifier: "CoffeeScaleQuestionStep"
                )?.results?.first as? ORKScaleQuestionResult
                if let answer = coffeeScale?.scaleAnswer {
                    countPerAnswer[answer] = (countPerAnswer[answer] ?? 0.0) + 1.0
                }
            }
            onCompletion(countPerAnswer)
        })
    }
}
