//
//  CKStudyUser.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import Firebase
import CardinalKit
import HealthKit
import EFStorageUserDefaults
import EFStorageKeychainAccess

extension Int: KeychainAccessStorable {
    public func asKeychainAccessStorable() -> Swift.Result<AsIsKeychainAccessStorable, Error> {
        return "\(self)".asKeychainAccessStorable()
    }

    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Int? {
        return String.fromKeychain(keychain, forKey: key).flatMap(Int.init)
    }
}

extension Date: KeychainAccessStorable { }

extension HKBiologicalSex: KeychainAccessStorable { }

class CKStudyUser: ObservableObject {
    
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
            return EFStorageKeychainAccessRef<String>
                .forKey(Constants.prefUserEmail)
                .content
        }
        set {
            objectWillChange.send()
            EFStorageKeychainAccessRef<String>
                .forKey(Constants.prefUserEmail)
                .content = newValue
        }
    }

    var name: String? {
        get {
            return currentUser?.displayName
        }
        set {
            guard let user = currentUser else { return }
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newValue
            changeRequest.commitChanges { [weak self] (error) in
                if let error = error {
                    print(error)
                } else {
                    self?.objectWillChange.send()
                }
            }
        }
    }

    var sex: HKBiologicalSex {
        get {
            return Keychain.efStorage.sex ?? .notSet
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.sex = newValue
        }
    }

    var dateOfBirth: Date? {
        get {
            return Keychain.efStorage.dob
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.dob = newValue
        }
    }

    var education: String? {
        get {
            return Keychain.efStorage.education
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.education = newValue
        }
    }

    var handedness: String? {
        get {
            return Keychain.efStorage.handedness
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.handedness = newValue
        }
    }

    var zipCode: String? {
        get {
            return Keychain.efStorage.zipCode
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.zipCode = newValue
        }
    }

    var ethnicity: String? {
        get {
            return Keychain.efStorage.ethnicity
        }
        set {
            objectWillChange.send()
            Keychain.efStorage.ethnicity = newValue
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
    
    /**
     Remove the current user's auth parameters from storage.
     */
    func signOut() throws {
        try Keychain.makeDefault().removeAll()
        try Auth.auth().signOut()
    }
}
