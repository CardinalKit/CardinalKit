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
import FirebaseCore

class FirebaseManager{
    class func transformDateToTimeStamp(date:Date?) -> Any {
        if let date = date {
            return Timestamp(date: date) as Any
        }
        return "" as Any
        
    }
    
    public func configure() {
        FirebaseApp.configure()
    }
    
    private func firestoreDb()->Firestore{
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }
    
    func transformTimeStampToDate(timeStamp:Any) -> Date? {
        if  let timeStamp = timeStamp as? Timestamp{
            return timeStamp.dateValue()
        }
        else{
            return nil
        }
    }
    
    
    
    func getDataFromCloudStorage(path:String,url:URL, OnCompletion: @escaping () -> Void, onError: @escaping (Error) -> Void){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let documentRef = storageRef.child("\(path)")
        let _ = documentRef.write(toFile: url) { _, error in
            if let error = error {
                onError(error)
            } else {
                OnCompletion()
            }

        }
    }
    
    func getUrlFileFromStorage(pathFile: String, onCompletion: @escaping (URL) -> Void, onError: @escaping (Error) -> Void){
        let storage = Storage.storage()
        let starsRef = storage.reference()
        let childRef = starsRef.child(pathFile)
        
        childRef.downloadURL{ url, error in
            if let error = error{
                onError(error)
            }
            else{
                onCompletion(url!)
            }
            
        }
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
            var userId = "NN"
            if let user = CKApp.instance.options.userDataProviderDelegate?.currentUserId{
                userId = user
            }
            let data = try Data(contentsOf: file)
            guard var json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                onCompletion(false)
                return
            }
            json["UpdatedBy"] = userId
            let db=firestoreDb()
            createNecessaryDocuments(path: authPath)
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
        var userId = "NN"
        if let user = CKApp.instance.options.userDataProviderDelegate?.currentUserId{
            userId = user
        }
        guard var json = data as? [String:Any]
        else {
            return
        }
        if let results = json["results"] as? [[String:Any]]{
            let results = FieldValue.arrayUnion(results)
            json["results"] = results
        }
        var documentData:[String:Any] = ["updatedAt":Date(),"UpdatedBy":userId]
        var merge=false
        if var params = params as? [String:Any] {
           if let merged = params["merge"] as? Bool{
                   params.removeValue(forKey: "merge")
                   merge=merged
               }
            documentData.append(params)
        }
        
        let db = firestoreDb()
        createNecessaryDocuments(path: route)
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
    
    func createNecessaryDocuments(path: String){
        var userId = "NN"
        if let user = CKApp.instance.options.userDataProviderDelegate?.currentUserId{
            userId = user
        }
        let _db=firestoreDb()
        let _pathArray = path.split{$0 == "/"}.map(String.init)
        var currentPath = ""
        var index=0
        for part in _pathArray{
            currentPath+=part
            if(index%2 != 0){
                _db.document(currentPath).setData(
                    [
                        "exist":"true",
                        "UpdatedBy":userId
                    ],
                    merge: true)
            }
            currentPath+="/"
            index+=1
        }
    }
    
    func get(route:String, onCompletion: @escaping ([String:Any]?) -> Void){
        let db = firestoreDb()
        
        let parts = route.split(separator: "/")
        if parts.count % 2 == 0{
            let ref = db.document(route)
            ref.getDocument{ (document, error) in
                if let document = document, document.exists,
                let payload = document.data(){
                    onCompletion(payload)
                } else {
                    onCompletion([:])
                }
            }
        }
        else{
            let ref = db.collection(route)
            ref.getDocuments(){ (querySnapshot, err) in
                var result:[String:Any] = [:]
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        result[document.documentID] = document.data()
                    }
                    onCompletion(result)
                }
            }
        } 
    }
    
    func getFilterdata(route: String, filter: [FilterModel], onCompletion: @escaping ([String : Any]?) -> Void) {
        let db = firestoreDb()
        let parts = route.split(separator: "/")
        guard parts.count % 2 != 0
        else{
            print("filter only valid for collection")
            onCompletion([:])
            return
        }
        let ref = db.collection(route)
        
        let completionHandler: (QuerySnapshot?, Error?)->Void = {
            (querySnapshot, err) in
            var result:[String:Any] = [:]
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    result[document.documentID] = document.data()
                }
                onCompletion(result)
            }
        }
        
        if filter.count > 0 {
            var query = ref.order(by: filter[0].field)
            for item in filter {
                switch item.filterType {
                case .GreaterOrEqualTo:
                    query = query.whereField(item.field, isGreaterThanOrEqualTo: item.value)
                case .GreaterThan:
                    query = query.whereField(item.field, isGreaterThan: item.value)
                case .LessOrEqualTo:
                    query = query.whereField(item.field, isLessThanOrEqualTo: item.value)
                case .LessThan:
                    query = query.whereField(item.field, isLessThan: item.value)
                case .equalTo:
                    query = query.whereField(item.field, isEqualTo: item.value)
                }
            }
            query.getDocuments(completion: completionHandler)
        }
        else{
            ref.getDocuments(completion: completionHandler)
        }
        
        
    }
    
}
