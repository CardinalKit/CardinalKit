//
//  CKTaskViewController.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import ResearchKit
import SwiftUI
import UIKit

struct CKTaskViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = ORKTaskViewController

    let viewController: ORKTaskViewController
    let delegate: CKUploadToGCPTaskViewControllerDelegate

    init(tasks: ORKOrderedTask) {
        self.viewController = ORKTaskViewController(task: tasks, taskRun: UUID())
        self.delegate = CKUploadToGCPTaskViewControllerDelegate()
    }
    
    func updateUIViewController(_ taskViewController: ORKTaskViewController, context: Context) { }

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        if viewController.outputDirectory == nil {
            viewController.outputDirectory = self.delegate.CKGetTaskOutputDirectory(viewController)
        }

        self.viewController.delegate = self.delegate // enables `ORKTaskViewControllerDelegate` below

        // & present the VC!
        return self.viewController
    }
}
