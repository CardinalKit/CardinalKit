//
//  CKStudyUser.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import CardinalKit

class CKStudyUser {
    
    static let shared = CKStudyUser()
    
//    /* **************************************************************
//     * the current user only resolves if we are logged in
//    **************************************************************/
//    var currentUser: User?
    
    /* **************************************************************
     * store your Firebase objects under this path in order to
     * be compatible with CardinalKit GCP rules.
    **************************************************************/
    var authCollection: String? {
        let authLibrary = Dependencies.container.resolve(AuthLibrary.self)!
        if let userId = authLibrary.user?.uid,
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
        let authLibrary = Dependencies.container.resolve(AuthLibrary.self)!
        return authLibrary.user != nil
    }    
}
