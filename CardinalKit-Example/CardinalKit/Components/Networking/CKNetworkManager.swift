//
//  CKAppNetworkManager.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import CardinalKit
import Firebase

class CKAppNetworkManager: CKAPIDeliveryDelegate {
    
    /**
     Override the CardinalKit networking engine to
     send HealthKit data using Firebase
    */
    fileprivate func sendHealthKit(_ file: URL, _ package: Package, _ onCompletion: @escaping (Bool) -> Void) {
        
        do {
            let data = try Data(contentsOf: file)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let authPath = CKSession.shared.getAuthCollection() else {
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
                    print("Document successfully written!")
                }
            }
            
        } catch {
            print("Error \(error.localizedDescription)")
            onCompletion(false)
            return
        }
        
    }
    
    // MARK: - CKAPIDeliveryDelegate
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        switch package.type {
        case .hkdata:
            sendHealthKit(file, package, onCompletion)
            break
        default:
            fatalError("Sending data of type \(package.type.description) is NOT supported.")
            break
        }
        
    }
    
}
