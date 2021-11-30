//
//  TestViewController.swift
//  CardinalKit_Example
//
//  Created by Julian Esteban Ramos Martinez on 7/09/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CareKit
import ResearchKit
import CareKitUI
import CareKitStore

class CheckListItemViewController: OCKChecklistTaskViewController, ORKTaskViewControllerDelegate{
    
    var task:OCKAnyTask? = nil;
    var indexPath:IndexPath? = nil;
    let collection: String = "surveys"
    
    override init(viewSynchronizer: OCKChecklistTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
        super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
        self.task = task
    }
    
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didSelectOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
        print(index)
    }
    
    override func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
        print(eventIndexPath)
    }
    
    override func taskView(_ taskView: UIView & OCKTaskDisplayable, didCompleteEvent isComplete: Bool, at indexPath: IndexPath, sender: Any?) {
        self.indexPath=indexPath;
        if  isComplete,
            let event = self.controller.eventFor(indexPath: indexPath),
            event.scheduleEvent.element.targetValues.count>0,
            let identifier = event.scheduleEvent.element.targetValues[0].groupIdentifier,
            let studyCollection = CKStudyUser.shared.studyCollection
            {
            let collectionI = "\(collection)/\(identifier)/questions"
            CKSendHelper.getFromFirestore(authCollection:studyCollection,collection: collectionI, onCompletion: { (documents,error) in
                guard let documents = documents,
                     documents.count>0 else {
                    super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
                   return
               }
                var objResult = [[String:Any]]()
                for document in documents{
                    if let data = document.data(){
                        objResult.append(data)
                    }
                    
                }
                objResult = objResult.sorted(by: {a,b in
                    if let order1 = a["order"] as? String,
                       let order2 = b["order"] as? String{
                        return Int(order1) ?? 1 < Int(order2) ?? 1
                    }
                    return true
                })
                guard objResult.count>0
                else{
                    super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
                    return
                }
                let surveyTask = JsonToSurvey.shared.GetSurvey(from: objResult,identifier: identifier)
                let surveyViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
                surveyViewController.delegate = self
                self.present(surveyViewController, animated: false, completion: nil)
            })
                
            }
        else{
            super.taskView(taskView, didCompleteEvent: isComplete, at: indexPath, sender: sender)
        }
    }
    // 3b. This method will be called when the user completes the survey.
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: false, completion: nil)
        if reason == .completed,
           let indexPath = self.indexPath{
            controller.appendOutcomeValue(value: true, at: indexPath, completion: nil)
            // 5. Upload results to GCP, using the CKTaskViewControllerDelegate class.
            let gcpDelegate = CKUploadToGCPTaskViewControllerDelegate()
            gcpDelegate.taskViewController(taskViewController, didFinishWith: reason, error: error)
        }
    }
}

class CheckListItemViewSynchronizer: OCKChecklistTaskViewSynchronizer {
    
//    override func makeView() -> OCKChecklistTaskView {
//        let instructionsView = super.makeView()
//
//        return instructionsView
//    }
    
//    override func updateView(_ view: OCKChecklistTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
//        super.updateView(view, context: context)
//        
//    }
}
