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
    public var networkReceiverDelegate : CKAPIReceiverDelegate?
    public init() {
        networkReceiverDelegate = CKAppNetworkManager()
        networkDeliveryDelegate = CKAppNetworkManager()
    }
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

    class public func requestData(route: String, onCompletion: @escaping (Any?) -> Void){
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.request(route: route, onCompletion: onCompletion)
        }
    }
    
    class public func sendData(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void )? = nil){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.send(route: route, data: data, params: params, onCompletion: onCompletion)
        }
    }
    
    class public func getHealthAuthorization(forTypes typesToCollect:Set<HKSampleType>, _ completion: @escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        CKActivityManager.shared.getHealthAuthorization(forTypes: typesToCollect) {(success, error) in
            completion(success, error)
            
        }
    }
}
