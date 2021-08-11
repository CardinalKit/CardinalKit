//
//  TaskItem.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 10/08/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import ResearchKit
import SwiftUI

struct TaskItem:Hashable {
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        true
    }    
    var title:String;
    var subtitle:String;
    var imageName: String;
    var section: String;
    
    var image: UIImage?{
        return UIImage(named: imageName) ?? UIImage(systemName: "questionmark.square")
    }
    
    var questions:[String];
    
    func View()->some View{
        return AnyView(CKTaskViewController(tasks: ORKOrderedTask.shortWalk(withIdentifier: "identifier", intendedUseDescription: "", numberOfStepsPerLeg: 1, restDuration: 5, options: ORKPredefinedTaskOption())))
    }
}
