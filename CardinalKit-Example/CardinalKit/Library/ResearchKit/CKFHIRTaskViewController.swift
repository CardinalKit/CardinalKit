//
//  CKFHIRTaskViewController.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 8/12/22.
//  Copyright © 2022 CardinalKit. All rights reserved.
//

import UIKit
import SwiftUI
import ResearchKit

struct CKFHIRTaskViewController: UIViewControllerRepresentable {

    let vc: ORKTaskViewController
    let delegate: CKUploadFHIRTaskViewControllerDelegate

    init(tasks: ORKOrderedTask) {
        self.vc = ORKTaskViewController(task: tasks, taskRun: NSUUID() as UUID)
        self.delegate = CKUploadFHIRTaskViewControllerDelegate()
    }

    typealias UIViewControllerType = ORKTaskViewController

    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) { }
    func makeUIViewController(context: Context) -> ORKTaskViewController {

        self.vc.delegate = self.delegate // enables `ORKTaskViewControllerDelegate` below

        // & present the VC!
        return self.vc
    }

}
