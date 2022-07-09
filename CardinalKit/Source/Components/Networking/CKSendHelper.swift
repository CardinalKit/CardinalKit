//
//  CKSendHelper.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

public class CKSendHelper {
    private static func firestoreDb()->Firestore{
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }
    /**
       This function creates the necessary documents in firebase adding a data to avoid virtual documents
     */
    public static func createNecessaryDocuments(path: String){
        let _db=firestoreDb()
        let _pathArray = path.split{$0 == "/"}.map(String.init)
        var currentPath = ""
        var index=0
        for part in _pathArray{
            currentPath+=part
            if(index%2 != 0){
                _db.document(currentPath).setData(["exist":"true"], merge: true)
            }
            currentPath+="/"
            index+=1
        }
    }
    
    /**
     Given a file, use the Firebase SDK to store it in Google Storage.
    */
    public static func sendToCloudStorage(_ files: URL, collection: String, withIdentifier identifier: String? = nil) throws {
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
            let ref = storageRef.child("\(authCollection)\(Constants.Firebase.dataBucketStorage)\(collection)/\(identifier ?? UUID().uuidString)/\(file.lastPathComponent)")
                        
            
            let uploadTask = ref.putFile(from: file, metadata: nil)
            
            uploadTask.observe(.success) { snapshot in
                print("[CKSendHelper] sendToCloudStorage() - file uploaded successfully!")
            }
            
            uploadTask.observe(.failure) { snapshot in
                print("[CKSendHelper] sendToCloudStorage() - error uploading file!")
            }
        }
    }
    
    
    enum CKError: Error {
        case unknownError
        case unauthorized
    }
}

