//
//  CKNetworkManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation

public protocol CKAPIRouteDelegate {
    func getAPIRoute(type: PackageType) -> String?
    func getWhitelistURLs() -> [String]
    func getHeaders() -> [String:String]?
}

public class CKNetworkManager : NSObject {
    
    
    
}
