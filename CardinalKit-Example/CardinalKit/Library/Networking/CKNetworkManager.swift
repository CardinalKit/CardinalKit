//
//  CKAppNetworkManager.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import CardinalKit
import Firebase

class CKAppNetworkManager: CKAPIDeliveryDelegate, CKAPIReceiverDelegate {
    // MARK: - CKAPIDeliveryDelegate
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self._send(file: file, package: package, onCompletion: onCompletion)
        }
    }
    
    fileprivate func _send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        switch package.type {
        case .hkdata:
            sendHealthKit(file, package, onCompletion)
        case .sensorData:
            sendSensorData(file, package, onCompletion)
        case .metricsData:
            sendMetricsData(file, package, onCompletion)
        default:
            fatalError("Sending data of type \(package.type.description) is NOT supported.")
        }
    }

    // MARK: - CKAPIReceiverDelegate
    func request(route: String, onCompletion: @escaping (Any) -> Void) {
        var objResult = [String: Any]()
        let database = firestoreDb()
        database.collection(route).getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    return
                }
                for document in documents {
                    objResult[document.documentID] = document.data()
                }
                onCompletion(objResult)
            }
        }
    }
    
    private func firestoreDb() -> Firestore {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let database = Firestore.firestore()
        database.settings = settings
        return db
    }
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
            
            let database = firestoreDb()
            database.collection(authPath + "\(Constants.dataBucketHealthKit)").document(trimmedIdentifier).setData(json) { err in
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
        guard let bucket = CKStudyUser.shared.authCollection else {
            return
        }
        
        let storageRef = Storage.storage().reference()
        let ref = storageRef.child("\(bucket)\(Constants.dataBucketStorage)/coremotion/\(package.fileName)/\(file.lastPathComponent)")
        
        let uploadTask = ref.putFile(from: file, metadata: nil)
        uploadTask.observe(.success) { _ in
            print("[sendSensorData] file uploaded successfully!")
        }
        
        uploadTask.observe(.failure) { _ in
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
            
            let identifier: String = (json["date"] as? String ?? Date().shortStringFromDate()) + "Activity_index"
            
            let database = firestoreDb()
            database.collection(authPath + "\(Constants.dataBucketMetrics)").document(identifier).setData(json) { err in
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
