//
//  ReceiverDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol CKReceiverDelegate {
    func request(route: String, onCompletion: @escaping (Any?) -> Void)
    func configure()
}

public class CKReceiver{
    
}

extension CKReceiver:CKReceiverDelegate{
    public func request(route: String, onCompletion: @escaping (Any?) -> Void) {
        
    }
    
    public func configure() {
        
    }
}
