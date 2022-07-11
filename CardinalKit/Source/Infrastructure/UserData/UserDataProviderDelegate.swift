//
//  UserDataProviderDelegate.swift
//  abseil
//
//  Created by Esteban Ramos on 1/07/22.
//

import Foundation
import FirebaseAuth

public protocol UserDataProviderDelegate{
    var currentUserId: String? {get}
    var authCollection: String? {get}
    var currentUserEmail: String? {get}
    var scheduleCollection: String? {get}
}

public class CKUserDataProvider: UserDataProviderDelegate {
    public var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    public var authCollection: String? {
        if let userId = Auth.auth().currentUser?.uid,
            let root = rootAuthCollection {
            return "\(root)\(userId)/"
        }
        
        return nil
    }
    
    public var scheduleCollection: String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/schedule"
        }
        return nil
    }
    
    public var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    fileprivate var rootAuthCollection: String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/users/"
        }
        return nil
    }
}
