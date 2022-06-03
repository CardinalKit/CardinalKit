//
//  CKNetworkManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

public protocol CKAPIRouteDelegate {
    func getAPIRoute(type: PackageType) -> String?
    func getWhitelistDomains() -> [String]
    func getHeaders() -> [String:String]?
}

public protocol CKAPIDeliveryDelegate {
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void)
    func send(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void)?)
}

public protocol CKAPIReceiverDelegate {
    func request(route: String, onCompletion: @escaping (Any?) -> Void)
}

public class CKNetworkManager : NSObject {

}


class CKAppNetworkManager: CKAPIDeliveryDelegate, CKAPIReceiverDelegate {    
    func send(route: String, data: Any, params: Any?,onCompletion: ((Bool, Error?) -> Void)?) {
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
    //            if overwriteRemote {
    //                ref.updateData(json, completion: completion)
    //            } else {
    //                ref.updateData(json, completion: completion)
    //            }
            print("[appendCareKitArrayInFirestore] updating revisions with overwriteRemote")
        }
        

    }

    func createNecessaryDocuments(path: String){
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

    // MARK: - CKAPIDeliveryDelegate
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async{
            self._send(file: file, package: package, onCompletion: onCompletion)
        }
    }
    
    fileprivate func _send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        switch package.type {
        case .hkdata:
            sendHealthKit(file, package, onCompletion)
            break
//        case .sensorData:
//            sendSensorData(file, package, onCompletion)
            break
        case .metricsData:
            sendMetricsData(file, package, onCompletion)
            break;
        default:
            fatalError("Sending data of type \(package.type.description) is NOT supported.")
            break
        }
    }
    // return dict { documentId: data }
    // MARK: - CKAPIReceiverDelegate
    func request(route: String, onCompletion: @escaping (Any?) -> Void){
            
            //Review if request is to a document or collections
            let routeComponents = route.components(separatedBy: "/")
            let db=firestoreDb()
            
            createNecessaryDocuments(path:route)
            
            // if is pair get collection
            if routeComponents.count%2==0{
                var objResult = [DocumentSnapshot]()
                
                db.collection(route).getDocuments(){ (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            objResult.append(document)
                        }
                        onCompletion(objResult)
                    }
                }
            }
            // else get document
            else{
                db.document(route).getDocument{ (document, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        if let document = document, document.exists{
                            onCompletion(document)
                        }
                        else{
                            onCompletion(nil)
                        }
                    }

                }
                
            }
            
           
        }

    
    private func firestoreDb()->Firestore{
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }
//    func downloadSurveys(){
//
//        guard let authPath = CKStudyUser.shared.authCollection else {
//            return
//        }
//
//
//        let db = Firestore.firestore()
////        let docRef = db.collection("cities").document("SF")
////        docRef.getDocument { (document, error) in
////            if let document = document, document.exists {
////                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
////                print("Document data: \(dataDescription)")
////            } else {
////                print("Document does not exist")
////            }
////        }
//    }
    
}

extension CKAppNetworkManager {
    
    /**
     Send HealthKit data using Firebase
    */
    fileprivate func sendHealthKit(_ file: URL, _ package: Package, _ onCompletion: @escaping (Bool) -> Void) {
        do {
            let data = try Data(contentsOf: file)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let authPath = CKStudyUser.shared.authCollection else {
                onCompletion(false)
                return
            }
            
            let identifier = Date().startOfDay.shortStringFromDate() + "-\(package.fileName)"
            let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespaces)
            
            let db=firestoreDb()
            db.collection(authPath + "\(Constants.Firebase.dataBucketHealthKit)").document(trimmedIdentifier).setData(json) { err in
                
                if let err = err {
                    onCompletion(false)
                    print("Error writing document: \(err)")
                } else {
                    onCompletion(true)
                    print("[sendHealthKit] \(trimmedIdentifier) - successfully written!")
                }
            }
            
        } catch {
            print("Error \(error.localizedDescription)")
            onCompletion(false)
            return
        }
    }
    
    /**
     Send Sensor data using Cloud Storage
    */
    fileprivate func sendSensorData(_ file: URL, _ package: Package, _ onCompletion: @escaping (Bool) -> Void) {
        
        guard let stanfordRITBucket = CKStudyUser.shared.authCollection else { return }
        
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child("\(stanfordRITBucket)\(Constants.Firebase.dataBucketStorage)/coremotion/\(package.fileName)/\(file.lastPathComponent)")
        
        let uploadTask = ref.putFile(from: file, metadata: nil)
        uploadTask.observe(.success) { snapshot in
            print("[sendSensorData] file uploaded successfully!")
        }
        
        uploadTask.observe(.failure) { snapshot in
            print("[sendSensorData] error uploading file!")
        }
    }
    
    fileprivate func sendMetricsData(_ file: URL, _ package: Package, _ onCompletion: @escaping (Bool) -> Void) {
        do {
            let data = try Data(contentsOf: file)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let authPath = CKStudyUser.shared.authCollection else {
                onCompletion(false)
                return
            }
            
            let identifier:String = (json["date"] as? String ?? Date().shortStringFromDate())+"Activity_index"
            
            let db=firestoreDb()
            db.collection(authPath + "\(Constants.Firebase.dataBucketMetrics)").document(identifier).setData(json) { err in
                
                if let err = err {
                    onCompletion(false)
                    print("Error writing document: \(err)")
                } else {
                    onCompletion(true)
                    print("[sendMetrics] \(identifier) - successfully written!")
                }
            }
            
        } catch {
            print("Error \(error.localizedDescription)")
            onCompletion(false)
            return
        }
    }
    
}
