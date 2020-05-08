//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation

public struct CKAppOptions {
    public var networkDelegate: CKAPIRouteDelegate?
    public init() { }
}

public class CKApp {
    
    public static let instance = CKApp()
    
    var networkDelegate: CKAPIRouteDelegate?
    
    class public func configure(_ options: CKAppOptions? = nil) {
        
        // CardinalKit Options
        instance.networkDelegate = options?.networkDelegate
        
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
