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
}

extension CKDelivery: CKDeliveryDelegate{
    public func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void) {
        
    }
    
    public func send(route: String, data: Any, params: Any?, onCompletion: ((Bool, Error?) -> Void)?) {
        
    }
    
    public func configure() {
        FirebaseApp.configure()
    }
}

