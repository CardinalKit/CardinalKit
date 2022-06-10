//
//  RealmManager.swift
//  Capacitor
//
//  Created by Santiago Gutierrez on 5/6/20.
//

import Foundation
import RealmSwift

class RealmManager :CKLocalDBDelegate{
    
    // Params expected Datatype
    // Device Source
    func getLastSyncItem(params: [String : AnyObject]) -> DateLastSyncObject? {
        let realm = try! Realm()
        
        let dataType =  params["dataType"]
        let device = params["device"]
        
        if let dataType = dataType as? String,
           let device = device as? String{
            let syncMetadataQuery = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "dataType = '\(dataType)'"),
                    NSPredicate(format: "device = '\(device)'")
                ])
            let results = realm.objects(DatesLastSyncRealmObject.self).filter(syncMetadataQuery)
            assert(results.count <= 1, "There should only be at most one sync date per type")
            if results.count > 0{
                if let result = results.first{
                    return RealmTraductors.TransformInObject(fromRealmObject: result)
                }
            }
        }
        return nil
    }
    
    func saveLastSyncItem(item: DateLastSyncObject) {
        let realmData = RealmTraductors.TransformInRealmObject(fromDateLastSyncObject: item)
        let realm = try! Realm()
        
        let realmObjects = realm.objects(DatesLastSyncRealmObject.self).filter("id == '\(realmData.id)'")
        if realmObjects.count > 0 {
            try! realm.write {
                realm.add(realmData, update: .modified)
            }
        }
        else{
            try! realm.write {
                realm.add(realmData)
            }
        }
        
        
    }
    
    func deleteLastSyncitem() {
        
    }
    
    func getNetworkItem(params: [String : AnyObject]) -> NetworkRequestObject? {
//        let realm = try! Realm()
        
    
        return nil
        
    }
    
    func saveNetworkItem(item: NetworkRequestObject) {
        let realmData = RealmTraductors.TransformInRealmObject(fromNetwortRequestObject: item)
        let realm = try! Realm()
        // Review if item previously exist or is new
        
        let realmObjects = realm.objects(NetworkRequestRealmObject.self).filter("id == \(item.id)")
        if realmObjects.count > 0 {
            try! realm.write {
                realm.add(realmData, update: .modified)
            }
        }
        else{
            try! realm.write {
                realm.add(realmData)
            }
        }
        
        
    }
    
    func deleteNetworkItem() {
        
    }
    
    func getNetworkItemsByFilter(filterQuery:String?) -> [NetworkRequestObject] {
        
        let realm = try! Realm()
        var realmObjects = realm.objects(NetworkRequestRealmObject.self)
        if let filterQuery = filterQuery {
            realmObjects = realmObjects.filter(filterQuery)
        }
        guard !realmObjects.isEmpty else {
            return []
        }
        var result:[NetworkRequestObject] = []
        for object in realmObjects {
            result.append(RealmTraductors.TransformInObject(fromRealmObject: object))
        }
        return result
    }
    
    
//
//    // Params
//    // NSPredicate ?
//    func getItem(params: [String : AnyObject]) -> [String:AnyObject] {
//
//        let realm = try! Realm()
//        let predicate = params["Predicate"]
//
//        if let predicate = predicate as? NSPredicate
//        {
//            let results = realm.objects(DataFormat.self).filter(predicate)
//            assert(results.count <= 1, "There should only be at most one sync date per type")
//            if results.count > 0{
//                if let result = results.first{
//                    return [
//                        "dataType":result.dataType as AnyObject,
//                        "lastSyncDate":result.lastSyncDate  as AnyObject,
//                        "device": result.device  as AnyObject
//                    ]
//                }
//            }
//        }
//        return [:]
//    }
//
//    func saveItem(params: [String : AnyObject]) {
//        let metadata = HealthKitDataUploads()
//        metadata.dataType = type.identifier
//        metadata.device = getSourceRevisionKey(source: sourceRevision)
//    }
//
//    func deleteItem(params: [String : AnyObject]) {
//
//    }
    
    func configure() -> Bool {
        let cacheLocation = CacheManager.shared.realmFile
        let config = Realm.Configuration(fileURL: cacheLocation, schemaVersion: 2, deleteRealmIfMigrationNeeded: true)
        
        VLog("[RealmManager:configure] setting up realm at location %@", cacheLocation?.absoluteString ?? "(unknown)")
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            let realm = try Realm()
            
            let fileURL = realm.configuration.fileURL
            if let fileURL = fileURL {
                let folderPath = fileURL.deletingLastPathComponent().path
                
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: folderPath)
                
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: fileURL.path)
                
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: fileURL.path + ".lock")
                
                try FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: fileURL.path + ".management")
                
            }
            
            VLog("[RealmManager:configure] success")
            return true
        } catch {
            VError("[RealmManager:configure] error %@", error.localizedDescription)
            return false
        }
    }
    
    fileprivate func realmMigrationBlock(_ migration: Migration, _ oldSchemaVersion: UInt64) {
        // nothing to migrate, yet.
    }
}

extension RealmManager{
    
}

