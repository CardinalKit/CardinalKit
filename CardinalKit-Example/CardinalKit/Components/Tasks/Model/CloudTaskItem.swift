//
//  CloudTaskItem.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 10/08/21.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Foundation
import ResearchKit
import SwiftUI
import UIKit

struct CloudTaskItem: Hashable {
    var order: String
    var title: String
    var subtitle: String
    var imageName: String
    var section: String
    var identifier: String
    
    var image: UIImage? {
        UIImage(named: imageName) ?? UIImage(systemName: "questionmark.square")
    }

    var questions: [String]

    static func == (lhs: CloudTaskItem, rhs: CloudTaskItem) -> Bool {
        lhs.title == rhs.title && lhs.section == rhs.section
    }

    func view() -> some View {
        var questionAsObj: [[String: Any]] = []
        for question in questions {
            guard let data = question.data(using: .utf8) else {
                continue
            }
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    questionAsObj.append(jsonArray)
                }
            } catch {
                print("Unable to parse JSON.")
            }
        }
        questionAsObj = questionAsObj.sorted(by: { first, second in
            if let order1 = first["order"] as? String,
               let order2 = second["order"] as? String {
                return Int(order1) ?? 1 < Int(order2) ?? 1
            }
            return true
        })

        return AnyView(
            CKTaskViewController(
                tasks: JsonToSurvey.shared.getSurvey(
                    from: questionAsObj,
                    identifier: identifier
                )
            )
        )
    }
}
