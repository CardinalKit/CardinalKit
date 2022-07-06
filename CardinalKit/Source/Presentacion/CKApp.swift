//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation


public struct CKAppOptions {
    public var networkDeliveryDelegate : CKDeliveryDelegate?
    public var networkReceiverDelegate : CKReceiverDelegate?
    public var localDBDelegate: CKLocalDBDelegate?
    public var userDataProviderDelegate: UserDataProviderDelegate?
    
    public init() {
        networkDeliveryDelegate = CKDelivery()
        networkReceiverDelegate = CKReceiver()
        userDataProviderDelegate = CKUserDataProvider()
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
    
    class public func getDataFromStorage(path:String, url:URL, onCompletion: @escaping (Bool, Error?) -> Void) {
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.requestFromStorage(path: path, url: url, OnCompletion: onCompletion)
        }
    }
    
    class public func sendData(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void )? = nil){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.send(route: route, data: data, params: params, onCompletion: onCompletion)
        }
    }
    
    class public func sendDataToCloudStorafe(route: String, files: URL, alsoSendToFirestore: Bool, firestoreRoute:String?,onCompletion: @escaping (Bool) -> Void){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.sendToCloud(files: files, route: route, alsoSendToFirestore: alsoSendToFirestore, firestoreRoute: firestoreRoute, onCompletion: onCompletion)
        }
    }
    
}

// HealthKit Functions
extension CKApp{
    
    class public func configureHealthKitTypes(types:Set<HKSampleType>, clinicalTypes: Set<HKSampleType>){
        instance.infrastructure.configure(types: types, clinicalTypes: clinicalTypes)
    }
    
    class public func startBackgroundDeliveryData(){
        instance.infrastructure.startBackgroundDeliveryData()
    }
    
    class public func collectData(fromDate startDate:Date, toDate endDate: Date){
        instance.infrastructure.collectData(fromDate: startDate, toDate: endDate)
    }
    
    class public func collectClinicalData(){
        instance.infrastructure.collectClinicalData()
    }
    
    class public func getHealthPermision(completion: @escaping (Result<Bool, Error>) -> Void) {
        instance.infrastructure.getHealthPermission(completion: completion)
    }
    
    class public func getClinicalPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
        instance.infrastructure.getClinicalPermission(completion: completion)
    }
}
