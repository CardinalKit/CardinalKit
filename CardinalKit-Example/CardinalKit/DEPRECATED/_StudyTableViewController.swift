//
//  StudyTableViewController.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit

/**
 This file represents what you see when tapping on
 the `Study` tab of your application!
*/
class StudyTableViewController: UITableViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show the current date at the very top
        dateLabel.text = Date().fullFormattedString()
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate
extension StudyTableViewController {
    
    /**
     How many rows do we want in our study tab table?
     Our app uses the`StudyTableItem` file to calculate this number!
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return StudyTableItem.allValues.count
    }
    
    /**
     We created a `StudyTableViewCell` with three elements:
     (1) a title, (2) a subtitle, and (3) a custom image.
     
     In this function define which `StudyTableItem` element we want to show
     and then we retrieve and display its content! 
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studyTableCell", for: indexPath) as! StudyTableViewCell
        
        if let activity = StudyTableItem(rawValue: (indexPath as NSIndexPath).row) {
            cell.titleLabel?.text = activity.title
            cell.subtitleLabel?.text = activity.subtitle
            cell.customImage.image = activity.image
        }
        
        return cell
    }
    
    /**
     What height do we want each row on our table to have?
    */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    /**
     What should we do when we select a specific item on the list?
    */
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        // did we assign a `StudyTableItem` element for this row?
//        guard let activity = StudyTableItem(rawValue: (indexPath as NSIndexPath).row) else { return }
//        
//        // If so, find out which kind of element
//        let taskViewController: ORKTaskViewController
//        switch activity {
//        case .survey:
//            /**
//              If we selected this element in our table, then wrap our `StudyTasks.sf12Task` in a
//             `ResearchKit` task view controller. See `StudyTasks` for `ORKTask` implementation.
//             */
//            taskViewController = ORKTaskViewController(task: StudyTasks.sf12Task, taskRun: NSUUID() as UUID)
//        case .activeTask:
//            /**
//             Wrap this element in a `StudyTasks.walkingTask`.
//             Separately, we set an `outputDirectory` since this step stores activity information.
//             
//             See documentation for `outputDirectory`: ~
//             If no output directory is specified, active steps that require writing data to disk, such as those with recorders, will typically fail at runtime.
//            */
//            taskViewController = ORKTaskViewController(task: StudyTasks.walkingTask, taskRun: NSUUID() as UUID)
//            taskViewController.outputDirectory = CKGetTaskOutputDirectory(taskViewController)
//        }
//        
//        // setting a delegate lets us override what happens when this ORKTaskViewController finishes
//        taskViewController.delegate = self
//        navigationController?.present(taskViewController, animated: true, completion: nil)
//    }
    
}

// MARK: - ORKTaskViewControllerDelegate
extension StudyTableViewController : ORKTaskViewControllerDelegate {
    
    /**
     Handle what happens when an `ORKTaskViewController` finishes.
    */
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        // TODO: make configurable; document how files are sent and stored.
        
        do {
            // (1) convert the result of the ResearchKit task into a JSON dictionary
            if let json = try CKTaskResultAsJson(taskViewController.result) {
                
                // (2) send using Firebase
                try CKSendJSON(json)
                
                // (3) if we have any files, send those using Google Storage
                if let associatedFiles = taskViewController.outputDirectory {
                    try CKSendFiles(associatedFiles, result: json)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // (4) we must dismiss the task when we are done with it, otherwise we will be stuck.
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
}
