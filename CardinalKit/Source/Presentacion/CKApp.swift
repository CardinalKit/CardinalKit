//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation
import HealthKit


public struct CKAppOptions {
    public var networkDeliveryDelegate : CKDeliveryDelegate?
    public var networkReceiverDelegate : CKReceiverDelegate?
    public var localDBDelegate: CKLocalDBDelegate?
    
    public init() {
        networkDeliveryDelegate = CKDelivery()
        networkReceiverDelegate = CKReceiver()
        localDBDelegate = CKLocalDB()
    }
}

public class CKApp{
    
    public static let instance = CKApp()
    
    var options = CKAppOptions()
    
    class public func configure(_ options: CKAppOptions? = nil) {
        
        // (1) initialize Firebase SDK
//        FirebaseApp.configure()
        
        // CardinalKit Options
        if let options = options {
            instance.options = options
        }
        
        instance.options.networkDeliveryDelegate?.configure()
        instance.options.networkReceiverDelegate?.configure()
        instance.options.localDBDelegate?.configure()
        
        
//        // Start listenig for changes in HealthKit items (waits for valid user inherently)
//        _ = CKActivityManager.shared.load()
//
//        // Realm
//        _ = RealmManager.shared.configure()
//
//        // Reinstallation/Unistallation
//        SessionManager.shared.checkFirstRun()
//
//        // Create cache directories with correct permissions
//        _ = CacheManager.shared.userContainer
//
//        configureWithValidUser()
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
    
    class public func getHealthAuthorizaton(forTypes typesToCollect:Set<HKSampleType>, _ completion: @escaping (_ success: Bool, _ error: Error?) -> Void)
    {
        CKActivityManager.shared.getHealthAuthorizaton(forTypes: typesToCollect) {(success, error) in
            completion(success, error)
        }
    }
    
    class public func signOut(){
//        try? Auth.auth().signOut()
    }
    
    func onDataCollected(data:HKSample){
        
    }
}
