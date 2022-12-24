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
    private let tasks: ORKOrderedTask
    private let delegate: ORKTaskViewControllerDelegate

    /// - Parameters:
    ///   - tasks: The `ORKOrderedTask` that should be displayed by the `ORKTaskViewController`
    ///   - delegate: An `ORKTaskViewControllerDelegate` that handles delegate calls from the `ORKTaskViewController`.
    ///   If no  view controller delegate is provided the view uses an instance of `CKUploadFHIRTaskViewControllerDelegate`.
    init(tasks: ORKOrderedTask, delegate: ORKTaskViewControllerDelegate = CKUploadFHIRTaskViewControllerDelegate()) {
        self.tasks = tasks
        self.delegate = delegate
    }

    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {}

    func makeUIViewController(context: Context) -> ORKTaskViewController {
        // Create a new instance of the view controller and pass in the assigned delegate.
        let viewController = ORKTaskViewController(task: tasks, taskRun: nil)
        viewController.delegate = delegate
        return viewController
    }
}
