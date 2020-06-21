//
//  StudyUser.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 9/22/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import Firebase
import CardinalKit

class StudyUser {
    
    static let shared = StudyUser()
    
    static let db = Firestore.firestore()
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    class func sendLoginLink(email: String, completion: @escaping (Bool)->Void) {
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
    
    func save() {
        
        if let dataBucket = RITConfig.shared.getRootCollection(),
            let email = currentUser?.email,
            let uid = currentUser?.uid {
            
            CKSession.shared.userId = uid
            
            let db = Firestore.firestore()
            db.collection(dataBucket).document(uid).setData(["userID":uid, "lastActive":Date().ISOStringFromDate(),"email":email])
        }
        
    }
    
    class func save(email: String) {
        UserDefaults.standard.set(email, forKey: Constants.prefUserEmail)
    }
    
    class func globalEmail() -> String? {
        return UserDefaults.standard.string(forKey: Constants.prefUserEmail)
    }
    
    class func loggedIn() -> Bool {
        return (StudyUser.shared.currentUser?.isEmailVerified ?? false) && UserDefaults.standard.bool(forKey: Constants.prefConfirmedLogin)
    }
    
    class func login(_ eid: String, completion: @escaping (Bool)->Void) {
        guard !eid.isEmpty else {
            completion(false)
            return
        }
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else {
                completion(false)
                return
            }
            
            userExists(eid, completion: { (document, exists) in
                if let document = document {
                    db.collection("users").document(document.documentID).setData(["userID":user.uid, "lastActive":Date().ISOStringFromDate()])
                } else if !exists {
                    db.collection("users").addDocument(data: ["eID": eid, "userID": user.uid, "lastActive":Date().ISOStringFromDate()])
                }
                
                completion(true)
            })
        }
    }
    
    class func userExists(_ eid: String, completion: @escaping (QueryDocumentSnapshot?, Bool)->Void) {
        
        db.collection("study_users").whereField("eid", isEqualTo: eid).getDocuments() { (snapshot, err) in
            guard let snapshot = snapshot else {
                //print(err?.localizedDescription)
                completion(nil, false)
                return
            }
            
            assert(snapshot.documents.count <= 1)
            completion(snapshot.documents.first, snapshot.documents.count == 1)
        }
        
    }
    
}
