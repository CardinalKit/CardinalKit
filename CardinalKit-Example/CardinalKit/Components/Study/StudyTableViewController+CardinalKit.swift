//
//  StudyTableViewController+CardinalKit.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit
import Firebase

extension StudyTableViewController {
    
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
        
        if  let identifier = json["identifier"] as? String,
            let taskUUID = json["taskRunUUID"] as? String,
            let authCollection = CKStudyUser.shared.authCollection,
            let userId = CKStudyUser.shared.currentUser?.uid {
            
            let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
            
            // If using the CardinalKit GCP instance, the authCollection
            // represents the directory that you MUST write to in order to
            // verify and access this data in the future.
            
            let db = Firestore.firestore()
            db.collection(authCollection + "\(Constants.dataBucketSurveys)").document(identifier + "-" + taskUUID).setData(dataPayload) { err in
                
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    // TODO: better configurable feedback via something like:
                    // https://github.com/Daltron/NotificationBanner
                    print("Document successfully written!")
                }
            }
            
        }
    }
    
    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
    */
    func CKSendFiles(_ files: URL, result: [String:Any]) throws {
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
                    try CKSendFiles(file, result: result) //cannot send a directory, recursively iterate into it
                    continue
                }
                
                let storageRef = Storage.storage().reference()
                let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/\(identifier)/\(taskUUID)/\(file.lastPathComponent)")
                
                let uploadTask = ref.putFile(from: file, metadata: nil)
                
                uploadTask.observe(.success) { snapshot in
                    // TODO: better configurable feedback via something like:
                    // https://github.com/Daltron/NotificationBanner
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
    
}
