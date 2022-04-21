//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation
import HealthKit


public struct CKAppOptions {
    internal var networkDeliveryDelegate : CKDeliveryDelegate?
    internal var networkReceiverDelegate : CKReceiverDelegate?
    internal var localDBDelegate: CKLocalDBDelegate?
    
    public init() {
        networkDeliveryDelegate = CKDelivery()
        networkReceiverDelegate = CKReceiver()
        // Using realm as local db
        localDBDelegate = RealmManager()
        
    }
}

public class CKApp{
    
    internal static let instance = CKApp()
    internal var infrastructure: Infrastructure
    var options = CKAppOptions()
    
    init(){
        infrastructure = Infrastructure()
    }
    
    class public func configure(_ options: CKAppOptions? = nil) {
        // CardinalKit Options
        if let options = options {
            instance.options = options
        }
        
        // Configure Delivery Delegate
        instance.options.networkDeliveryDelegate?.configure()
        // Configure Receiver Delegate
        instance.options.networkReceiverDelegate?.configure()
        // Configure Local DB
        _ = instance.options.localDBDelegate?.configure()
        
        // TODO: Session manager
        // TODO: Configuration of Cache manager?
        // TODO: Configuration of user
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
    
}

// HealthKit Functions
extension CKApp{
    class public func startBackgroundDeliveryData(){
        instance.infrastructure.startBackgroundDeliveryData()
    }
    
    class public func collectData(fromDate startDate:Date, toDate endDate: Date){
        instance.infrastructure.collectData(fromDate: startDate, toDate: endDate)
    }
    
    class public func getHealthPermision(completion: @escaping (Result<Bool, Error>) -> Void) {
        instance.infrastructure.getHealthPermission(completion: completion)
    }
//    func onDataCollected(data:[HKSample]){
//     // TODO: Send Data
//        CKApp.sendData(route: "/studies/com.alternova.example/users/ycgo26IN3aR8dZ6D0fvIonteoMe2/surveys/testSurvey", data: data, params: ["testin11","testingResult"]){ success, error in
//            print("Oncomplete send")
//        }
//        print("Data Collected \(data)")
//    }
}
