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
import EFStorageKeychainAccess

extension Int: KeychainAccessStorable {
    public func asKeychainAccessStorable() -> Swift.Result<AsIsKeychainAccessStorable, Error> {
        return "\(self)".asKeychainStorable()
    }

    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Int? {
        return String.fromKeychain(keychain, forKey: key).flatMap(Int.init)
    }
}

extension HKBiologicalSex: KeychainAccessStorable { }

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

    var name: String? {
        get {
            return currentUser?.displayName
        }
        set {
            guard let user = currentUser else { return }
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newValue
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    var sex: HKBiologicalSex {
        get {
            return EFStorageKeychainAccessRef<HKBiologicalSex>.forKey("SEX").content ?? .notSet
        }
        set {
            EFStorageKeychainAccessRef<HKBiologicalSex>.forKey("SEX").content = newValue
        }
    }

    var dateOfBirth: DateComponents? {
        get {
            guard let year: Int = Keychain.efStorage.dobYear,
                  let month: Int = Keychain.efStorage.dobMonth,
                  let day: Int = Keychain.efStorage.dobDay
            else { return nil }
            return DateComponents(year: year, month: month, day: day)
        }
        set {
            Keychain.efStorage.dobYear = newValue?.year
            Keychain.efStorage.dobMonth = newValue?.month
            Keychain.efStorage.dobDay = newValue?.day
        }
    }

    var education: String? {
        get {
            return Keychain.efStorage.education
        }
        set {
            Keychain.efStorage.education = newValue
        }
    }

    var handedness: String? {
        get {
            return Keychain.efStorage.handedness
        }
        set {
            Keychain.efStorage.handedness = newValue
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
        email = nil
        sex = .notSet
        dateOfBirth = nil
        education = nil
        handedness = nil
        try Auth.auth().signOut()
    }
}
