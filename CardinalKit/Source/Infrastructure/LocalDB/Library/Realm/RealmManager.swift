//
//  RealmManager.swift
//  Capacitor
//
//  Created by Santiago Gutierrez on 5/6/20.
//

import Foundation
import RealmSwift

class RealmManager :CKLocalDBDelegate{
    
    // get object type DateLastSyncObject based on data type and device
    func getLastSyncItem(dataType:String,device:String ) -> DateLastSyncObject? {
        let realm = try! Realm()
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
        return nil
    }
    
    // Save object type DateLastSyncObject
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
        // TODO: delete sync items
    }
    
    func getNetworkItem(params: [String : AnyObject]) -> NetworkRequestObject? {
        // TODO: get specific networkItems
        return nil
        
    }
    
    func saveNetworkItem(item: NetworkRequestObject) {
        let realmData = RealmTraductors.TransformInRealmObject(fromNetwortRequestObject: item)
        let realm = try! Realm()
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
        // TODO: delete networkItems
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

