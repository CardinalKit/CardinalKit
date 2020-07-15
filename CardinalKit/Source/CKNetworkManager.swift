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
}

public protocol CKAPIDeliveryDelegate {
    func send(file: URL, package: Package, onCompletion: @escaping (Bool) -> Void)
}

public class CKNetworkManager : NSObject {

}
