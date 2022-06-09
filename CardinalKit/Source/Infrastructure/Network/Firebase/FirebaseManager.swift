//
//  FirebaseManager.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 4/04/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager{
    private func firestoreDb()->Firestore{
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }
    
    func sendToCloudStorage (file:URL,route:String){
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child("\(route)/\(file.lastPathComponent)")
        let uploadTask = ref.putFile(from: file, metadata: nil)
        
        uploadTask.observe(.success) { snapshot in
            print("[FirebaseManager] sendToCloudStorage() - file uploaded successfully!")
        }
        
        uploadTask.observe(.failure) { snapshot in
            print("[FirebaseManager] sendToCloudStorage() - error uploading file!")
        }
    }
    
    func send(file: URL, package: Package,authPath:String,identifier:String, onCompletion: @escaping (Bool) -> Void) {
        do {
            let data = try Data(contentsOf: file)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                onCompletion(false)
                return
            }
            
            let db=firestoreDb()
            db.collection(authPath).document(identifier).setData(json) { err in
                
                if let err = err {
                    onCompletion(false)
                    print("Error writing document: \(err)")
                } else {
                    onCompletion(true)
                    print("[sendHealthKit] \(identifier) - successfully written!")
                }
            }
            
        } catch {
            print("Error \(error.localizedDescription)")
            onCompletion(false)
            return
        }
    }
    
    func send(route: String, data: Any, params: Any?, onCompletion: ((Bool, Error?) -> Void)?) {
        
        let user = Auth.auth().currentUser;
        if (user == nil){
            print( "no Logged ")
        }
        else{
            print(" Logged")
        }
        guard let json = data as? [String:Any]
        else {
            return
        }
        
        var documentData:[String:Any] = ["updatedAt":Date()]
        var merge=false
        if var params = params as? [String:Any] {
           if let merged = params["merge"] as? Bool{
                   params.removeValue(forKey: "merge")
                   merge=merged
               }
            documentData.append(params)
        }
        
        let db = firestoreDb()
//        createNecessaryDocuments(path: route)
        let ref = db.document(route)
        ref.setData(documentData, merge: merge)
        
        if !json.isEmpty {
            
            ref.updateData(json, completion: {err in
                if let err = err {
                    print("[appendCareKitArrayInFirestore] error writing document: \(err)")
                    onCompletion?(false, err)
                } else {
                    print("[appendCareKitArrayInFirestore] document successfully written!")
                    onCompletion?(true, nil)
                }
            })
            print("[appendCareKitArrayInFirestore] updating revisions with overwriteRemote")
        }
    }
    
    func Get(){
        
    }
}

