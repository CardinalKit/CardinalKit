//
//  ActivitiesTableViewController.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit
import ResearchKit
import Firebase

class ActivitiesTableViewController: UITableViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dateLabel.text = Date().fullFormattedString()
    }
}

extension ActivitiesTableViewController {
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        
        return ActivityTableItem.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standardTableCell", for: indexPath) as! ActivityTableViewCell
        
        if let activity = ActivityTableItem(rawValue: (indexPath as NSIndexPath).row) {
            cell.titleLabel?.text = activity.title
            cell.subtitleLabel?.text = activity.subtitle
            cell.customImage.image = activity.image
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let activity = ActivityTableItem(rawValue: (indexPath as NSIndexPath).row) else { return }
        
        let taskViewController: ORKTaskViewController
        switch activity {
        case .survey:
            taskViewController = ORKTaskViewController(task: StudyTasks.sf12Task, taskRun: NSUUID() as UUID)
        case .activeTask:
            taskViewController = ORKTaskViewController(task: StudyTasks.walkingTask, taskRun: NSUUID() as UUID)
            
            do {
                let defaultFileManager = FileManager.default
                
                // Identify the documents directory.
                let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                
                // Create a directory based on the `taskRunUUID` to store output from the task.
                let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
                try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
                
                taskViewController.outputDirectory = outputDirectory
            }
            catch let error as NSError {
                fatalError("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
            }
        }
        
        taskViewController.delegate = self
        navigationController?.present(taskViewController, animated: true, completion: nil)
    }
    
}

extension ActivitiesTableViewController: ORKTaskViewControllerDelegate {
    
    func resultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
        let jsonData = try ORKESerializer.jsonData(for: result)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
    }
    
    func send(_ json: [String:Any]) throws {
        if  let identifier = json["identifier"] as? String,
            let taskUUID = json["taskRunUUID"] as? String,
            let stanfordRITBucket = CKStudyUser.shared.authCollection,
            let userId = CKStudyUser.shared.currentUser?.uid {
            
            let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
            
            let db = Firestore.firestore()
            db.collection(stanfordRITBucket + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in
                
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
        }
    }
    
    func send(_ files: URL, result: [String:Any]) throws {
        if  let identifier = result["identifier"] as? String,
            let taskUUID = result["taskRunUUID"] as? String,
            let stanfordRITBucket = CKStudyUser.shared.authCollection {
            
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                var isDir : ObjCBool = false
                guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                    continue //no file exists
                }
                
                if isDir.boolValue {
                    try send(file, result: result) //cannot send a directory, recursively iterate into it
                    continue
                }
                
                let storageRef = Storage.storage().reference()
                let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")
                
                let uploadTask = ref.putFile(from: file, metadata: nil)
                
                uploadTask.observe(.success) { snapshot in
                    print("File uploaded successfully!")
                }
                
                uploadTask.observe(.failure) { snapshot in
                    print("Error uploading file!")
                    /*if let error = snapshot.error as NSError? {
                        switch (StorageErrorCode(rawValue: error.code)!) {
                        case .objectNotFound:
                            // File doesn't exist
                            break
                        case .unauthorized:
                            // User doesn't have permission to access file
                            break
                        case .cancelled:
                            // User canceled the upload
                            break
                            
                            /* ... */
                            
                        case .unknown:
                            // Unknown error occurred, inspect the server response
                            break
                        default:
                            // A separate error occurred. This is a good place to retry the upload.
                            break
                        }
                    }*/
                }
                
            }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        // Handle results using taskViewController.result
        do {
            if let json = try resultAsJson(taskViewController.result) {
                try send(json)
                
                if let associatedFiles = taskViewController.outputDirectory {
                    try send(associatedFiles, result: json)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
}

