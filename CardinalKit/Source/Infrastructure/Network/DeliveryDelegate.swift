//
//  DeliveryDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

import FirebaseCore

public protocol CKDeliveryDelegate {
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void)
    func send(route: String, data: Any, params: Any?, onCompletion:((Bool, Error?) -> Void)?)
    func sendToCloud(files:URL, route: String, alsoSendToFirestore:Bool, firestoreRoute:String?, onCompletion: @escaping (Bool) -> Void)
    func configure()
}

public class CKDelivery{
    var firebaseManager: FirebaseManager
    
    init(){
        firebaseManager = FirebaseManager()
    }
}

extension CKDelivery: CKDeliveryDelegate{
    public func sendToCloud(files: URL, route: String, alsoSendToFirestore:Bool = false, firestoreRoute:String?,onCompletion: @escaping (Bool) -> Void){
        do {
            let fileManager = FileManager.default
            let fileURLs = try fileManager.contentsOfDirectory(at: files, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                var isDir : ObjCBool = false
                guard FileManager.default.fileExists(atPath: file.path, isDirectory:&isDir) else {
                    continue //no file exists
                }
                if isDir.boolValue {
                    sendToCloud(files: file, route: route,alsoSendToFirestore: alsoSendToFirestore, firestoreRoute: firestoreRoute, onCompletion: onCompletion)
                    //cannot send a directory, recursively iterate into it
                    continue
                }
                firebaseManager.sendToCloudStorage(file: file, route: route)
                
                if alsoSendToFirestore{
                    let contents = try String(contentsOf: file)
                    let data = contents.data(using: .utf8)!
                    
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,AnyObject>
                    {
                        let dataType:String = file.lastPathComponent.contains("accel") ? "Acelerometer" : file.lastPathComponent.contains("deviceMotion") ? "DeviceMotion" : "Other"
                        send(route: "\(firestoreRoute!)/\(dataType)/\(file.lastPathComponent)", data: jsonArray, params: nil, onCompletion: nil)
                    } else {
                        print("bad json")
                    }
                }
            }
        }
        catch{
            
        }
        
    }
    
    public func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        switch package.type {
        case .hkdata:
            sendHealthKit(file, package, onCompletion)
            break
        case .metricsData:
            sendMetricsData(file, package, onCompletion)
            break;
        default:
            fatalError("Sending data of type \(package.type.description) is NOT supported.")
            break
        }
    }
    
    public func send(route: String, data: Any, params: Any?, onCompletion: ((Bool, Error?) -> Void)?) {
        firebaseManager.send(route: route, data: data, params: params, onCompletion: onCompletion)
    }
    
    public func configure() {
        FirebaseApp.configure()
    }
}

extension CKDelivery{
    private func sendHealthKit(_ file: URL,_ package: Package,_ onCompletion: @escaping (Bool) -> Void) {
        if let authPath = CKStudyUser.shared.authCollection{
            
            let identifier = Date().startOfDay.shortStringFromDate() + "-\(package.fileName)"
            let trimmedIdentifier = identifier.trimmingCharacters(in: .whitespaces)
            
            firebaseManager.send(file: file, package: package, authPath: authPath + "\(Constants.Firebase.dataBucketHealthKit)",identifier: trimmedIdentifier, onCompletion: onCompletion)
        }
        else{
            onCompletion(false)
        }
        
    }
    private func sendSensorData(_ file: URL,_ package: Package,_ onCompletion: @escaping (Bool) -> Void) {}
    private func sendMetricsData(_ file: URL,_ package: Package,_ onCompletion: @escaping (Bool) -> Void) {
        if let authPath = CKStudyUser.shared.authCollection {
            let identifier:String = package.identifier
            firebaseManager.send(file: file, package: package, authPath: authPath + "\(Constants.Firebase.dataBucketHealthKit)", identifier: identifier,onCompletion: onCompletion)
            
        }
    }
    
}

