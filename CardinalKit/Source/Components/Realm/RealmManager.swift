//
//  RealmManager.swift
//  Capacitor
//
//  Created by Santiago Gutierrez on 5/6/20.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
    func configure() -> Bool {
        // let config = Realm.Configuration(schemaVersion: 2, migrationBlock: realmMigrationBlock)
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
