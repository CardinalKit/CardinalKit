//
//  CKStudyUser.swift
//  CardinalKit
//
//  Created by Julian Esteban Ramos Martinez on 7/01/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    
    var surveysCollection: String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/surveys/"
        }
        
        return nil
    }
    
    var studyCollection: String?{
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/"
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
            return UserDefaults.standard.string(forKey: Constants.UserDefaults.prefUserEmail)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.prefUserEmail)
            } else {
                UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.prefUserEmail)
            }
        }
    }
    
    var isLoggedIn: Bool {
        return (currentUser?.isEmailVerified ?? false) && UserDefaults.standard.bool(forKey: Constants.UserDefaults.prefConfirmedLogin)
    }

    /**
    Save a snapshot of our current user into Firestore.
    */
    func save() {
        if let dataBucket = rootAuthCollection,
            let email = currentUser?.email,
            let uid = currentUser?.uid {
            
            CKSession.shared.userId = uid
            createNecessaryDocuments(path:dataBucket)
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            let db = Firestore.firestore()
            db.settings = settings
            db.collection(dataBucket).document(uid).setData(
                ["userID": uid,
                 "lastActive": Date().ISOStringFromDate(),
                 "email": email
                ]
            )
        }
    }
    
    /**
    Remove the current user's auth parameters from storage.
    */
    func signOut() throws {
        email = nil
        try Auth.auth().signOut()
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
    
    func firestoreDb()->Firestore{
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }
}
