//
//  RealmDataFormats.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 7/04/22.
//

import Foundation
import RealmSwift

class DatesLastSyncRealmObject: Object {
    @objc dynamic var id:String = ""
    @objc dynamic var dataType: String = ""
    @objc dynamic var lastSyncDate: Date = Date()
    @objc dynamic var device: String = ""
   
    override class func primaryKey() -> String? {
        return "id"
    }
}

class NetworkRequestRealmObject: Object{
    @objc dynamic var id = -1
    @objc dynamic var fileName: String? //name of file that contains Data
    @objc dynamic var fileType: String? //walk test data, etc. Used to decide endpoint
    @objc dynamic var createdAt: Date?
    @objc dynamic var sentOn: Date?
    @objc dynamic var processing: Bool = false
    @objc dynamic var lastAttempt: Date?
    @objc dynamic var attempts: Int = 0
    
    override var description: String {
        return "Task #\(id) : \(fileName ?? "(no fileName)") \(fileType ?? "(no fileType)") \(sentOn?.ISOStringFromDate() ?? "(never delivered)") \(processing)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// Transform CardinalKit Models into a Realm Objects to use in Realm Bd
class RealmTraductors{
    class func TransformInRealmObject(fromDateLastSyncObject object:DateLastSyncObject)->DatesLastSyncRealmObject{
        
        let realmObject = DatesLastSyncRealmObject()
        realmObject.dataType = object.dataType
        realmObject.lastSyncDate = object.lastSyncDate
        realmObject.device = object.device
        realmObject.id = "\(object.dataType)-\(object.device)"
        
        return realmObject
    }
    
    class func TransformInObject(fromRealmObject realmObject:DatesLastSyncRealmObject) -> DateLastSyncObject{
        return DateLastSyncObject(
            dataType: realmObject.dataType,
            lastSyncDate: realmObject.lastSyncDate,
            device: realmObject.device
        )
    }
    
    class func TransformInRealmObject(fromNetwortRequestObject object:NetworkRequestObject) -> NetworkRequestRealmObject{
        
        let realmObject = NetworkRequestRealmObject()
        
        realmObject.id = object.id
        realmObject.fileName = object.fileName
        realmObject.fileType = object.fileType
        realmObject.createdAt = object.createdAt
        realmObject.sentOn = object.sentOn
        realmObject.processing = object.processing
        realmObject.lastAttempt = object.lastAttempt
        realmObject.attempts = object.attempts
        
        return realmObject
    }
    
    class func TransformInObject(fromRealmObject realmObject:NetworkRequestRealmObject) -> NetworkRequestObject{
        let networkRequest = NetworkRequestObject(id: realmObject.id)
        networkRequest.fileName = realmObject.fileName
        networkRequest.fileType = realmObject.fileType
        networkRequest.createdAt = realmObject.createdAt
        networkRequest.sentOn = realmObject.sentOn
        networkRequest.processing = realmObject.processing
        networkRequest.lastAttempt = realmObject.lastAttempt
        networkRequest.attempts = realmObject.attempts
        return networkRequest
    }
    
    
}
