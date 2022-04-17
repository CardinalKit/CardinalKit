//
//  LocalDBDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol CKLocalDBDelegate{
    func configure() -> Bool
    func getLastSyncItem(params: [String : AnyObject]) -> DateLastSyncObject?
    func saveLastSyncItem(item:DateLastSyncObject)
    func deleteLastSyncitem()
    func getNetworkItem(params: [String : AnyObject]) -> NetworkRequestObject?
    func saveNetworkItem(item:NetworkRequestObject)
    func deleteNetworkItem()
}
