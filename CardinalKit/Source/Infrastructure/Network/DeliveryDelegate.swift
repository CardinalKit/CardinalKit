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
    func configure()
}

public class CKDelivery{
    var firebaseManager: FirebaseManager
    
    init(){
        firebaseManager = FirebaseManager()
    }
}

extension CKDelivery: CKDeliveryDelegate{
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

