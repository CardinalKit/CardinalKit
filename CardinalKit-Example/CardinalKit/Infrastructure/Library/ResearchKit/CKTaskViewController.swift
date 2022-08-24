//
//  CKTaskViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI
import ResearchKit

struct CKTaskViewController: UIViewControllerRepresentable {
    
    let vc: ORKTaskViewController
    let delegate: CKUploadToGCPTaskViewControllerDelegate
    
    init(tasks: ORKOrderedTask) {
        self.vc = ORKTaskViewController(task: tasks, taskRun: NSUUID() as UUID)
        self.delegate = CKUploadToGCPTaskViewControllerDelegate()
    }

    typealias UIViewControllerType = ORKTaskViewController
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) { }
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        
        if vc.outputDirectory == nil {
            vc.outputDirectory = self.delegate.CKGetTaskOutputDirectory(vc)
        }
        
        self.vc.delegate = self.delegate // enables `ORKTaskViewControllerDelegate` below
        
        // & present the VC!
        return self.vc
    }
    
}
