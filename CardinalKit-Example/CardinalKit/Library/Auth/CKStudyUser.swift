//
//  CKStudyUser.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import CardinalKit
import Firebase
import Foundation


class CKStudyUser: ObservableObject {
    static let shared = CKStudyUser()

    private weak var authStateHandle: AuthStateDidChangeListenerHandle?

    /* **************************************************************
     * the current user only resolves if we are logged in
     **************************************************************/
    var currentUser: User? {
        Auth.auth().currentUser
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

    var studyCollection: String? {
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
            UserDefaults.standard.string(forKey: Constants.prefUserEmail)
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
        (currentUser?.isEmailVerified ?? false) && UserDefaults.standard.bool(forKey: Constants.prefConfirmedLogin)
    }

    init() {
        // listen for changes in authentication state from Firebase and update currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.objectWillChange.send()
        }
    }

    deinit {
        // remove the authentication state handle when the instance is deallocated
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    /**
     Send a login email to the user.

     At this stage, we do not have a `currentUser` via Google Identity.

     - Parameters:
     - email: validated address that should receive the sign-in link.
     - completion: callback
     */
    func sendLoginLink(email: String, completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty else {
            completion(false)
            return
        }

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://cs342.page.link")
        actionCodeSettings.handleCodeInApp = true // The sign-in operation has to always be completed in the app.

        if let bundleId = Bundle.main.bundleIdentifier {
            actionCodeSettings.setIOSBundleID(bundleId)
        }

        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
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
            CKSendHelper.createNecessaryDocuments(path: dataBucket)
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            let database = Firestore.firestore()
            database.settings = settings
            database.collection(dataBucket).document(uid).setData(
                [
                    "userID": uid,
                    "lastActive": Date().ISOStringFromDate(),
                    "email": email
                ],
                merge: true
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
}
