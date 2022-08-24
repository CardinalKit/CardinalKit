//
//  CKAppDelegate.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation

/**
 Structure to configure the different protocols used by CardinalKit

 -  networkDeliveryDelegate: Protocol for sending data
 -  networkReceiverDelegate: Protocol for receiving data
 -  localDBDelegate:     Protocol for implementing a local database
 -  userDataProviderDelegate:  Protocol to query the different user paths
 */
public struct CKAppOptions {
    public var networkDeliveryDelegate : CKDeliveryDelegate?
    public var networkReceiverDelegate : CKReceiverDelegate?
    public var localDBDelegate: CKLocalDBDelegate?
    // TODO: change userDataProvider to a more descriptive name
    public var userDataProviderDelegate: UserDataProviderDelegate?
    
    /**
     Initialize the protocols with the ones used by cardinalKit by default
              - by default firebase is used as external database and realm as internal database
     */
    public init() {
        networkDeliveryDelegate = CKDelivery()
        networkReceiverDelegate = CKReceiver()
        userDataProviderDelegate = CKUserDataProvider()
        localDBDelegate = RealmManager()
    }
}

/// Presentation layer of DDD architecture
/// This layer is the part where interaction with external systems happens. 
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
    }
}

// Request data from the external database
extension CKApp{
    /**
     Request data from a specific route
     - Parameter route: the path from where the data will be requested
     - Parameter onCompletion:closure that will be executed when the request is completed can return any object
     */
    class public func requestData(route: String, onCompletion: @escaping (Any?) -> Void){
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.request(route: route, onCompletion: onCompletion)
        }
    }
    
    /**
     Request filtered data from a specific route
     - Parameter route: the path from where the data will be requested
     - Parameter filters: array of objects of type FilterModel to perform filters
        FilterModel {
            var field:String
            var filterType:FilterType
            var value:Any
        }
         public enum FilterType {
             case GreaterThan
             case GreaterOrEqualTo
             case LessThan
             case LessOrEqualTo
             case equalTo
         }
     Example FilterModel(field:"user",filterType:.equealTo,value:"123")
     - Parameter onCompletion:Closure that will be executed when the request is completed can return any object
     */
    class public func requestDataWithFilters(route: String, filters:[FilterModel], onCompletion: @escaping (Any?) -> Void){
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.requestFilter(route: route, filter: filters, onCompletion: onCompletion)
        }
    }
    
    /**
     Request the calendar items of a specific date

     - Parameter date: Date to filter the events
     - Parameter onCompletion: Closure that is executed with the response of the events, returns an array of (scheduleModel)
     */
    class public func requestScheduleItems(date: Date, onCompletion: @escaping ([ScheduleModel]) -> Void){
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.requestScheduleItems(date: date, onCompletion: onCompletion)
        }
    }
    
    /**
     Get a public url of a file located in firebase storage

     - Parameter path: firebase storage path where the file is stored
     - Parameter onCompletion: Closure that is executed with the response of URL
     - Parameter onError: Closure that is executed when an error occurs it may be that the path does not exist
     */
    class public func requestUrlFromStorage(path: String, onCompletion: @escaping (URL) -> Void, onError: @escaping (Error) -> Void){
        if let delegate = CKApp.instance.options.networkReceiverDelegate{
            delegate.requestUrlFromStorage(path:path, onCompletion: onCompletion, onError:onError)
        }
    }
    
    /**
     Get a file from Firebase storage and save in specific Url Folder

     - Parameter path: firebase storage path where the file is stored
     - Parameter url:  path where we want to save the file
     - Parameter onCompletion: Closure that is executed with the response (Bool if the download is correct and Error if an error occurs)
     */
    class public func getDataFromStorage(path:String, url:URL, onCompletion: @escaping (Bool, Error?) -> Void) {
        if let delegate = CKApp.instance.options.networkReceiverDelegate {
            delegate.requestFromStorage(path: path, url: url, OnCompletion: onCompletion)
        }
    }
}

// Send data to external database
extension CKApp{
    
    /**
     Send data to firebase (any type of data) (any configurable Paramater)
        By defect Ck send Json data parameters: "merge" boolean to true if you need to merge the data in firebase
     - Parameter route: path where you want to save your data
     - Parameter data:  data in the format required by your CK database delegate receives any json
     - Parameter params: configurable parameters of your database, ck receives the boolean merge
     - Parameter onCompletion: Closure that is executed with the response (Bool if the upload is correct and Error if an error occurs)
     */
    class public func sendData(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void )? = nil){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.send(route: route, data: data, params: params, onCompletion: onCompletion)
        }
    }
    
    /**
     Send file to firebase
     - Parameter route: path where you want to save your data
     - Parameter files:  address of the folder or file you want to send
     - Parameter alsoSendToFirestore: mark this boolean to true if you also want the data to be saved in plain text in firebase
     - Parameter onCompletion: Closure that is executed with the response (Bool if the upload is correct )
     */
    class public func sendDataToCloudStorage(route: String, files: URL, alsoSendToFirestore: Bool, firestoreRoute:String?,onCompletion: @escaping (Bool) -> Void){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.sendToCloud(files: files, route: route, alsoSendToFirestore: alsoSendToFirestore, firestoreRoute: firestoreRoute, onCompletion: onCompletion)
        }
    }
    
    /**
     Create calendar events
     - Parameter route: path where you want to save your event
     - Parameter items:array of type ScheduleModel to create the events
     ScheduleModel
     {
         public let title:String
         public let instructions:String
         public let id:String
         public let type:ScheduleModelType
         public let surveyId:String?
         public let startDate: Date
         public let endDate: Date?
         public let interval: Interval
     }
     
     - Parameter onCompletion: Closure that is executed with the response (Bool if the upload is correct )
     */
    class public func createScheduleItems(route:String, items:[ScheduleModel], onCompletion: @escaping (Bool) -> Void){
        if let delegate = CKApp.instance.options.networkDeliveryDelegate{
            delegate.createScheduleItems(route: route, items: items, onCompletion: onCompletion)
        }
    }
}

// HealthKit Functions
extension CKApp{
    
    /**
     Tell cardinal kit what types of healthkit data you want to collect
     - Parameter types: what types of healthkit do you want to collect
     - Parameter clinicalTypes: what types of clinical data you want to collect
     */
    class public func configureHealthKitTypes(types:Set<HKSampleType>, clinicalTypes: Set<HKSampleType>){
        instance.infrastructure.configure(types: types, clinicalTypes: clinicalTypes)
    }
    
    /**
     start background data collection
     */
    class public func startBackgroundDeliveryData(){
        instance.infrastructure.startBackgroundDeliveryData()
    }
    
    /**
     collect data between two specific dates
     */
    class public func collectData(fromDate startDate:Date, toDate endDate: Date){
        instance.infrastructure.collectData(fromDate: startDate, toDate: endDate)
    }
    
    /**
     collect all clinical documents
     */
    class public func collectClinicalData(){
        instance.infrastructure.collectClinicalData()
    }
    
    /**
     ask the user for permissions to healthkit data
     */
    class public func getHealthPermision(completion: @escaping (Result<Bool, Error>) -> Void) {
        instance.infrastructure.getHealthPermission(completion: completion)
    }
    
    /**
     ask the user for permissions to clinical docs
     */
    class public func getClinicalPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
        instance.infrastructure.getClinicalPermission(completion: completion)
    }
}
