//
//  RITConfig.swift
//  Master-Sample
//
//  Created by Santiago Gutierrez on 11/10/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

class RITConfig {
    
    static let shared = RITConfig()
    
    func getRootCollection() -> String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/users/"
        }
        
        return nil
    }
    
    func getAuthCollection() -> String? {
        if let userId = StudyUser.shared.currentUser?.uid,
            let root = getRootCollection() {
            return "\(root)\(userId)/"
        }
        
        return nil
    }
    
}
