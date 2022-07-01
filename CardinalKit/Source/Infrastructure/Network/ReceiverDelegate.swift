//
//  ReceiverDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol CKReceiverDelegate {
    func request(route: String, onCompletion: @escaping ([String:Any]?) -> Void)
    func requestFromStorage(path:String,url:URL, OnCompletion: @escaping (Bool, Error?) -> Void)
    func configure()
}

public class CKReceiver{
    var firebaseManager: FirebaseManager
    
    init(){
        firebaseManager = FirebaseManager()
    }
}

extension CKReceiver:CKReceiverDelegate{
    public func request(route: String, onCompletion: @escaping ([String:Any]?) -> Void) {
        firebaseManager.get(route: route, onCompletion: onCompletion)
    }
    
    public func requestFromStorage(path:String,url:URL, OnCompletion: @escaping (Bool, Error?) -> Void){
        firebaseManager.getDataFromCloudStorage(path: path, url: url,
                                                OnCompletion: {OnCompletion(true,nil)},
                                                onError: { error in OnCompletion(false,error)}
        )
    }
    
    public func configure() {
        
    }
}
