//
//  DownloadManager.swift
//  CardinalKit
//
//  Created by Julian Esteban Ramos Martinez on 6/08/21.
//

import Foundation

class DownloadManager: NSObject {
    public static let shared = DownloadManager()
    
    func fetchData(route: String, onCompletion: @escaping (Any) -> Void){
        if let customDelegate = CKApp.instance.options.networkReceiverDelegate{
            customDelegate.request(route: route, onCompletion: onCompletion)
        }
        else{
            // Return surveys by defect
        }
    }
    
}
