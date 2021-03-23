//
//  CKAppNetworkManager.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import CardinalKit
import Firebase

class CKAppNetworkManager: CKAPIDeliveryDelegate {
    
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
            break
        case .sensorData:
            sendSensorData(file, package, onCompletion)
            break
        default:
            fatalError("Sending data of type \(package.type.description) is NOT supported.")
            break
        }
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
            
            let db = Firestore.firestore()
            db.collection(authPath + "\(Constants.dataBucketHealthKit)").document(trimmedIdentifier).setData(json) { err in
                
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
        let ref = storageRef.child("\(stanfordRITBucket)\(Constants.dataBucketStorage)/coremotion/\(package.fileName)/\(file.lastPathComponent)")
        
        let uploadTask = ref.putFile(from: file, metadata: nil)
        uploadTask.observe(.success) { snapshot in
            print("[sendSensorData] file uploaded successfully!")
        }
        
        uploadTask.observe(.failure) { snapshot in
            print("[sendSensorData] error uploading file!")
        }
    }
    
}
