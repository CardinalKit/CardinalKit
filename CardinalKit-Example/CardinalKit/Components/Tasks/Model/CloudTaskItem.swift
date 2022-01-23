//
//  CloudTaskItem.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 10/08/21.
//  Copyright © 2021 CardinalKit. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit
import SwiftUI

struct CloudTaskItem: Hashable {
    static func == (lhs: CloudTaskItem, rhs: CloudTaskItem) -> Bool {
        return lhs.title == rhs.title && lhs.section == rhs.section
    }
    
    var order: String;
    var title:String;
    var subtitle:String;
    var imageName: String;
    var section: String;
    var identifier: String;
    
    var image: UIImage?{
        return UIImage(named: imageName) ?? UIImage(systemName: "questionmark.square")
    }
    
    var questions:[String];
    
    func View()->some View{
        var questionAsObj:[[String:Any]] = []
        for question in questions{
            let data = question.data(using: .utf8)!
            do{
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
                {
                    questionAsObj.append(jsonArray)
                }
            }
            catch{
                print("bad Json")
            }
        }
        questionAsObj = questionAsObj.sorted(by: {a,b in
            if let order1 = a["order"] as? String,
               let order2 = b["order"] as? String{
                return Int(order1) ?? 1 < Int(order2) ?? 1
            }
            return true
        })
        
        
        return AnyView(CKTaskViewController(tasks: JsonToSurvey.shared.GetSurvey(from: questionAsObj,identifier: identifier)))
    }
}
