//
//  CKStudyUser.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import Firebase
import CardinalKit

class CKStudyUser {
    
    static let shared = CKStudyUser()
    
    /* **************************************************************
     * the current user only resolves if we are logged in
    **************************************************************/
    var currentUser: User? {
        // this is a reference to the
        // Firebase + Google Identity User
        return Auth.auth().currentUser
    }
    
    /* **************************************************************
     * store your Firebase objects under this path in order to
     * be compatible with CardinalKit GCP rules.
    **************************************************************/
    var authCollection: String? {
        if let userId = currentUser?.uid,
            let root = rootAuthCollection {
            return "\(root)\(userId)/"
        }
        
        return nil
    }
    
    fileprivate var rootAuthCollection: String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/users/"
        }
        
        return nil
    }

    var email: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.prefUserEmail)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: Constants.prefUserEmail)
            } else {
                UserDefaults.standard.removeObject(forKey: Constants.prefUserEmail)
            }
        }
    }
    
    var isLoggedIn: Bool {
        return (currentUser?.isEmailVerified ?? false) && UserDefaults.standard.bool(forKey: Constants.prefConfirmedLogin)
    }
    
    /**
    Send a login email to the user.

    At this stage, we do not have a `currentUser` via Google Identity.

    - Parameters:
        - email: validated address that should receive the sign-in link.
        - completion: callback
    */
    func sendLoginLink(email: String, completion: @escaping (Bool)->Void) {
        guard !email.isEmpty else {
            completion(false)
            return
        }
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://cs342.page.link")
        actionCodeSettings.handleCodeInApp = true // The sign-in operation has to always be completed in the app.
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { (error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            completion(true)
        }
    }

    /**
    Save a snapshot of our current user into Firestore.
    */
    func save() {
        if let dataBucket = rootAuthCollection,
            let email = currentUser?.email,
            let uid = currentUser?.uid {
            
            CKSession.shared.userId = uid
            
            let db = Firestore.firestore()
            db.collection(dataBucket).document(uid).setData(["userID":uid, "lastActive":Date().ISOStringFromDate(),"email":email])
        }
    }
    
    func saveMedication(medication: Medication) {
        if let dataBucket = rootAuthCollection,
            let uid = currentUser?.uid {
            
            CKSession.shared.userId = uid
            
//            let jsonObject: NSMutableDictionary = NSMutableDictionary()
//
//            jsonObject.setValue(medication.name, forKey: "name")
//            jsonObject.setValue(medication.dosage, forKey: "dosage")
//            jsonObject.setValue(medication.unit, forKey: "unit")
//            jsonObject.setValue(medication.times, forKey: "times")
            
            let medicationString = medication.id + "," + medication.name + "," + medication.dosage + "," + medication.unit + "," + medication.times.joined(separator: ",")
            
            let db = Firestore.firestore()
            db.collection(dataBucket).document(uid).updateData([
                "medications": FieldValue.arrayUnion([medicationString])
            ])
        }
    }
    
    func deleteMedication(medication: Medication) {
        if let dataBucket = rootAuthCollection,
            let uid = currentUser?.uid {
            
            CKSession.shared.userId = uid
            
//            let jsonObject: NSMutableDictionary = NSMutableDictionary()
//
//            jsonObject.setValue(medication.id, forKey: "id")
//            jsonObject.setValue(medication.name, forKey: "name")
//            jsonObject.setValue(medication.dosage, forKey: "dosage")
//            jsonObject.setValue(medication.unit, forKey: "unit")
//            jsonObject.setValue(medication.times, forKey: "times")
            
            let medicationString = medication.id + "," + medication.name + "," + medication.dosage + "," + medication.unit + "," + medication.times.joined(separator: ",")
            
            let db = Firestore.firestore()
            db.collection(dataBucket).document(uid).updateData([
                "medications": FieldValue.arrayRemove([medicationString])
            ])
        }
    }
    

    /**
    Remove the current user's auth parameters from storage.
    */
    func signOut() throws {
        email = nil
        try Auth.auth().signOut()
    }
    
}
