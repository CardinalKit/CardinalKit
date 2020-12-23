//
//  CKSendHelper.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Firebase

class CKSendHelper {
    
    /**
     Parse a JSON Data object and convert to a dictionary.
    */
    static func jsonDataAsDict(_ jsonData: Data) throws -> [String:Any]? {
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
    }
    
    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
    */
    static func sendToFirestore(_ json: [String:Any], collection: String, withIdentifier identifier: String? = nil) throws {
        if  let authCollection = CKStudyUser.shared.authCollection,
            let userId = CKStudyUser.shared.currentUser?.uid {
            
            let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
            
            // If using the CardinalKit GCP instance, the authCollection
            // represents the directory that you MUST write to in order to
            // verify and access this data in the future.
            
            let db = Firestore.firestore()
            db.collection(authCollection + "\(collection)")
                .document(identifier ?? UUID().uuidString)
                .setData(dataPayload) { err in
                
                if let err = err {
                    print("[CKSendHelper] sendToFirestore() - error writing document: \(err)")
                } else {
                    print("[CKSendHelper] sendToFirestore() - document successfully written!")
                }
            }
            
        }
    }
    
    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
    */
    static func sendToCloudStorage(_ files: URL, collection: String, withIdentifier identifier: String? = nil) throws {
        if let authCollection = CKStudyUser.shared.authCollection {
            
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                var isDir : ObjCBool = false
                guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                    continue //no file exists
                }
                
                if isDir.boolValue {
                    try sendToCloudStorage(file, collection: collection, withIdentifier: identifier) //cannot send a directory, recursively iterate into it
                    continue
                }
                
                let storageRef = Storage.storage().reference()
                let ref = storageRef.child("\(authCollection)\(Constants.dataBucketStorage)\(collection)/\(identifier ?? UUID().uuidString)/\(file.lastPathComponent)")
                
                let uploadTask = ref.putFile(from: file, metadata: nil)
                
                uploadTask.observe(.success) { snapshot in
                    print("[CKSendHelper] sendToCloudStorage() - file uploaded successfully!")
                }
                
                uploadTask.observe(.failure) { snapshot in
                    print("[CKSendHelper] sendToCloudStorage() - error uploading file!")
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
