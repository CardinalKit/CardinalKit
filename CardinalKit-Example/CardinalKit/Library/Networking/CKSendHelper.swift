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
     Use the Firebase SDK to retrieve a document with a specific ID.
     */
    static func getFromFirestore(collection: String, identifier: String, onCompletion: @escaping (DocumentSnapshot?, Error?)->Void) {
        
        guard let authCollection = CKStudyUser.shared.authCollection else {
            onCompletion(nil, CKError.unauthorized)
            return
        }
        
        let db = Firestore.firestore()
        let ref = db.collection(authCollection + "\(collection)").document(identifier)
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                onCompletion(document, error)
                print("[getFromFirestore] successfully retrieved document: \(collection)/\(identifier)")
            } else {
                print("[getFromFirestore] unable to retrieve document: \(collection)/\(identifier)")
                print("[getFromFirestore] error: \(error?.localizedDescription ?? "<unknown>")")
                onCompletion(nil, error)
            }
        }
        
        
    }
    
    /**
     Given a JSON dictionary (as Data), use the Firebase SDK to store it in Firestore.
    */
    static func sendToFirestoreWithUUID(data: Data, collection: String, withIdentifier identifier: String? = nil, onCompletion: ((Bool, Error?) -> Void)? = nil) throws {
        let dictionary = try CKSendHelper.jsonDataAsDict(data)
        return try CKSendHelper.sendToFirestoreWithUUID(json: dictionary!, collection: collection, withIdentifier: identifier, onCompletion: onCompletion)
    }
    
    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
    */
    static func sendToFirestoreWithUUID(json: [String:Any], collection: String, withIdentifier identifier: String? = nil, onCompletion: ((Bool, Error?) -> Void)? = nil) throws {
        guard let authCollection = CKStudyUser.shared.authCollection,
              let userId = CKStudyUser.shared.currentUser?.uid else {
            onCompletion?(false, CKError.unauthorized)
            return
        }
            
        let dataPayload: [String:Any] = ["userId":"\(userId)", "payload":json]
        
        // If using the CardinalKit GCP instance, the authCollection
        // represents the directory that you MUST write to in order to
        // verify and access this data in the future.
        
        let db = Firestore.firestore()
        db.collection(authCollection + "\(collection)")
            .document(identifier ?? UUID().uuidString)
            .setData(dataPayload) { err in
            
            if let err = err {
                print("[CKSendHelper] sendToFirestoreWithUUID() - error writing document: \(err)")
                onCompletion?(false, err)
            } else {
                print("[CKSendHelper] sendToFirestoreWithUUID() - document successfully written!")
                onCompletion?(true, nil)
            }
        }
    }
    
    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
    */
    static func appendResearchKitResultToFirestore(json: [String:Any], collection: String, withIdentifier identifier: String? = nil, onCompletion: ((Bool, Error?) -> Void)? = nil) throws {
        guard let authCollection = CKStudyUser.shared.authCollection,
              let userId = CKStudyUser.shared.currentUser?.uid,
              let identifier = identifier,
              !json.isEmpty else {
            onCompletion?(false, CKError.unauthorized)
            return
        }
            
        let dataPayload: [String:Any] = ["userId":"\(userId)", "updatedAt": Date()]
        
        let db = Firestore.firestore()
        db.collection(authCollection + collection).document(identifier).setData(dataPayload, merge: true)
        
        func completion(_ err: Error?) {
            if let err = err {
                print("[appendResultToFirestore] error writing document: \(err)")
                onCompletion?(false, err)
            } else {
                print("[appendResultToFirestore] document successfully written!")
                onCompletion?(true, nil)
            }
        }
        
        let ref = db.collection(authCollection + collection).document(identifier)
        ref.updateData([
            "results": FieldValue.arrayUnion([json])
        ], completion: completion)
        
    }
    
    /**
     This function updates an array in Firestore!
    */
    static func appendCareKitArrayInFirestore(json: [String:Any], collection: String, withIdentifier identifier: String, overwriteRemote: Bool = false, onCompletion: ((Bool, Error?) -> Void)? = nil) {
        guard let authCollection = CKStudyUser.shared.authCollection else {
            onCompletion?(false, CKError.unauthorized)
            return
        }
        
        let db = Firestore.firestore()
        db.collection(authCollection + collection).document(identifier).setData(["updatedAt": Date()], merge: true)
        let ref = db.collection(authCollection + collection).document(identifier)
        if !json.isEmpty {
            
            func completion(_ err: Error?) {
                if let err = err {
                    print("[appendCareKitArrayInFirestore] error writing document: \(err)")
                    onCompletion?(false, err)
                } else {
                    print("[appendCareKitArrayInFirestore] document successfully written!")
                    onCompletion?(true, nil)
                }
            }
            
            if overwriteRemote {
                ref.updateData([
                    "revisions": [json]
                ], completion: completion)
            } else {
                ref.updateData([
                    "revisions": FieldValue.arrayUnion([json])
                ], completion: completion)
            }
            print("[appendCareKitArrayInFirestore] updating revisions with overwriteRemote \(overwriteRemote)")
        }
    }
    
    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
    */
    static func sendToCloudStorage(_ files: URL, collection: String, withIdentifier identifier: String? = nil) throws {
        guard let authCollection = CKStudyUser.shared.authCollection else { return }
            
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
