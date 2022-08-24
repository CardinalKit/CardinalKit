//
//  LocalDBDelegate.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation


/**
 protocol necessary for the implementation of the local database
    Cardinal kit uses two models to save to local database
    DateLastSyncObject used to save the last time a healthKit data type was synced
    NetworkRequestObject used to save a local copy of all data that is attempted to be sent to an external database
 
 */
public protocol CKLocalDBDelegate{
    func configure() -> Bool
    func getLastSyncItem(dataType:String,device:String) -> DateLastSyncObject?
    func saveLastSyncItem(item:DateLastSyncObject)
    func deleteLastSyncitem()
    // TODO: add network
    func getNetworkItem(params: [String : AnyObject]) -> NetworkRequestObject?
    func saveNetworkItem(item:NetworkRequestObject)
    func deleteNetworkItem()
    func getNetworkItemsByFilter(filterQuery:String?) -> [NetworkRequestObject] 
}
