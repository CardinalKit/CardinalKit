//
//  SurveyItemViewController.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 8/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CareKitUI
import CareKit
import ResearchKit
import CardinalKit

class SurveyItemViewController:OCKInstructionsTaskViewController, ORKTaskViewControllerDelegate {
    var task:TaskItem
    var scheduleItem:ScheduleModel
    
    init(task:TaskItem,scheduleItem:ScheduleModel, storeManager: OCKSynchronizedStoreManager) {
        self.task = task
        self.scheduleItem = scheduleItem
        super.init(controller: OCKInstructionsTaskController(storeManager: storeManager), viewSynchronizer: CKSynchronizer(item: scheduleItem))
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: false, completion: nil)
        guard reason == .completed else {
               taskView.completionButton.isSelected = false
               return
           }
        taskView.completionButton.isSelected = true
    }
    
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {
        super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
        if !isComplete {
            return
        }
        let surveyController = ORKTaskViewController(task: self.task.tasks, taskRun: nil)
        surveyController.delegate = self
        present(surveyController, animated: false)
        self.taskView.completionButton.isSelected = false
    }
}

class CKSynchronizer: OCKInstructionsTaskViewSynchronizer{
    var item:ScheduleModel
    
    init(item:ScheduleModel) {
        self.item = item
        // Search Survey Data
        super.init()
    }
    
    override func makeView() -> OCKInstructionsTaskView {
        let instructionsView = super.makeView()
        instructionsView.headerView.detailLabel.text = self.item.title
        instructionsView.headerView.titleLabel.text = self.item.instructions
        instructionsView.completionButton.label.text = "Complete Survey"
        return instructionsView
    }
    
    override func updateView(_ view: OCKInstructionsTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
        // Search if is complete or not
        view.completionButton.isSelected = false
    }
}
