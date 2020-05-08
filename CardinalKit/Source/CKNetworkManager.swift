//
//  CKNetworkManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation

public protocol CKAPIRouteDelegate {
    func getAPIRoute(type: PackageType) -> String?
    func getWhitelistDomains() -> [String]
    func getHeaders() -> [String:String]?
    
    //POST: URL
    //<with headers>
    
    //need network delivery override methods for GCP-interactions
}

public class CKNetworkManager : NSObject {

}
