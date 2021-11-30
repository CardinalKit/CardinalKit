//
//  CKTaskViewControllerDelegate.swift
//  CareKit Sample
//
//  Created by Santiago Gutierrez on 2/14/21.
//

import Foundation
import CareKit
import ResearchKit
import Firebase

class CKUploadToGCPTaskViewControllerDelegate : NSObject, ORKTaskViewControllerDelegate {
        
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
           do {
                // (1) convert the result of the ResearchKit task into a JSON dictionary
                //if let json = try CKTaskResultAsJson(taskViewController.result) {
                if let json = try   CK_ORKSerialization.CKTaskAsJson(result: taskViewController.result,task: taskViewController.task!) {
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
            fallthrough
        default:
            taskViewController.dismiss(animated: false, completion: nil)
            
        }
    }
    
    /**
    Create an output directory for a given task.
    You may move this directory.
     
     - Returns: URL with directory location
    */
    func CKGetTaskOutputDirectory(_ taskViewController: ORKTaskViewController) -> URL? {
        do {
            let defaultFileManager = FileManager.default
            
            // Identify the documents directory.
            let documentsDirectory = try defaultFileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // Create a directory based on the `taskRunUUID` to store output from the task.
            let outputDirectory = documentsDirectory.appendingPathComponent(taskViewController.taskRunUUID.uuidString)
            try defaultFileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
            
            return outputDirectory
        }
        catch let error as NSError {
            print("The output directory for the task with UUID: \(taskViewController.taskRunUUID.uuidString) could not be created. Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /**
     Parse a result from a ResearchKit task and convert to a dictionary.
     JSON-friendly.

     - Parameters:
        - result: original `ORKTaskResult`
     - Returns: [String:Any] dictionary with ResearchKit `ORKTaskResult`
    */
    func CKTaskResultAsJson(_ result: ORKTaskResult) throws -> [String:Any]? {
        let jsonData = try ORKESerializer.jsonData(for: result)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
    }
    
    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
    */
    func CKSendJSON(_ json: [String:Any]) throws {
        let identifier = (json["identifier"] as? String) ?? UUID().uuidString
            
        try CKSendHelper.appendResearchKitResultToFirestore(json: json, collection: Constants.dataBucketSurveys, withIdentifier: identifier, onCompletion: nil)
    }
    
    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
    */
    func CKSendFiles(_ files: URL, result: [String:Any]) throws {
        if  let collection = result["identifier"] as? String,
            let taskUUID = result["taskRunUUID"] as? String {
            
            try CKSendHelper.sendToCloudStorage(files, collection: collection, withIdentifier: taskUUID)
        }
    }
    
}
