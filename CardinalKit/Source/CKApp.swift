//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation

public struct CKAppOptions {
    public var networkRouteDelegate: CKAPIRouteDelegate?
    public var networkDeliveryDelegate : CKAPIDeliveryDelegate?
    public init() { }
}

public class CKApp {
    
    public static let instance = CKApp()
    
    var options = CKAppOptions()
    
    class public func configure(_ options: CKAppOptions? = nil) {
        
        // CardinalKit Options
        if let options = options {
            instance.options = options
        }
        
        // Start listenig for changes in HealthKit items (waits for valid user inherently)
        _ = CKActivityManager.shared.load()
        
        // Realm
        _ = RealmManager.shared.configure()
        
        // Reinstallation/Unistallation
        SessionManager.shared.checkFirstRun()
        
        // Create cache directories with correct permissions
        _ = CacheManager.shared.userContainer
        
        configureWithValidUser()
    }

    class func configureWithValidUser() {
        guard SessionManager.shared.userId != nil else {
            return
        }
        
        // Start listening for network changes
        _ = NetworkTracker.shared
        
        // Start Watch Manager
        //_ = WatchConnectivityManager.shared
    }

    
}
