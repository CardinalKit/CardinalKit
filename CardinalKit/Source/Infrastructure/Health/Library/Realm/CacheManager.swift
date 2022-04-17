//
//  CacheManager.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 12/5/17.
//  Copyright © 2017 VascTrac. All rights reserved.
//

import Foundation

enum CacheType : String {
    case network = "cardinalkit.network"
    case walkTest = "cardinalkit.walktest"
}

class CacheManager : NSObject {
    
    static let shared = CacheManager()
    
    let parentContainer = "\(Constants.app)"
    let realmContainerPath = "\(Constants.app).realm"
    
    lazy var documents: URL? = {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        try? FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: docs.path)
        
        return docs
    }()
    
    lazy var appContainer: URL? = {
        guard let docs = documents else {
            return nil
        }
        
        let parentDir = docs.appendingPathComponent(parentContainer)
        if !mk(dir: parentDir) {
            return nil
        }
        
        return parentDir
    }()
    
    lazy var realmContainer: URL? = {
        guard let docs = documents else {
            return nil
        }
        
        let realmDir = docs.appendingPathComponent(realmContainerPath)
        if !mk(dir: realmDir) {
            return nil
        }
        
        return realmDir
    }()
    
    lazy var realmFile: URL? = {
        guard let realm = realmContainer else {
            return nil
        }
        
        return realm.appendingPathComponent("cardinalkit.realm")
    }()
    
    var userContainer: URL? { //not lazy because userId needs to be valid after log-in and log-out
        #if os(watchOS)
        return appContainer //watch is user-agnostic
        #else
        
        guard let container = appContainer, let userId = SessionManager.shared.userId else {
            
            //userId is enforced in the event that a user withdraws and re-logs in as under a different id. If a package resolves as the incorrect location, the resulting upload will be undesirably stored under the wrong userId.
            return nil
        }
        
        let userDir = container.appendingPathComponent(userId)
        if !mk(dir: userDir) {
            return nil
        }
        
        return userDir
        
        #endif
    }
    
    lazy var temporary: URL? = {
        let temp = FileManager.default.temporaryDirectory
        
        let tempDir = temp.appendingPathComponent(parentContainer)
        if !mk(dir: tempDir) {
            return nil
        }
        
        return tempDir
    }()
    
    func getPackageContainer(fileType: PackageType) -> URL? {
        guard let container = userContainer else {
            return nil
        }
        
        let packageDir = container.appendingPathComponent(fileType.rawValue)
        if !mk(dir: packageDir) {
            return nil
        }
        
        return packageDir
    }
    
    func getPackageStore(fileName name: String, fileType type: PackageType) -> URL? {
        guard let store = getPackageContainer(fileType: type) else {
            return nil
        }
        
        return store.appendingPathComponent(name)
    }
    
    func getTemporaryFolder(_ name: String) -> URL? {
        guard let temp = temporary else {
            return nil
        }
        
        let newFolder = temp.appendingPathComponent(name)
        if !mk(dir: newFolder) {
            return nil
        }
        
        return newFolder
    }
    
    //returns only .ZIP files
    func getZipContents(fileType type: PackageType) -> [URL]? {
        guard let parentDirectory = getPackageContainer(fileType: type) else {
            return nil
        }
        
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: parentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return contents.compactMap({ (url) -> URL? in
                if url.pathExtension != "zip" {
                    return nil
                }
                return url
            })
        } catch {
            return nil
        }
    }
    
    func createSnapshop() -> [String] {
        guard let documents = documents else {
            return [String]()
        }
        
        
        let enumerator = FileManager.default.enumerator(atPath: documents.path)
        var result = [String]()
        while let element = enumerator?.nextObject() as? String {
            result.append(element)
        }
        return result
    }
    
    func createSnapshotData() -> Data? {
        guard let documents = documents else {
            return nil
        }
        
        let enumerator = FileManager.default.enumerator(atPath: documents.path)
        var result = "Snapshot of \(documents.path)\n"
        while let element = enumerator?.nextObject() as? String {
            result += "\(element)\n"
        }
        result += "----------------------------------"
        
        return result.data(using: .utf8)
    }
    
}

extension CacheManager {
    
    fileprivate func mk(dir: URL) -> Bool {
        var isDir : ObjCBool = false
        if !FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) || !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
            } catch {
                VError("Unable to create directory @", error.localizedDescription)
                return false
            }
        } else {
            try? FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: dir.path)
        }
        return true
    }
    
}

extension CacheManager {
    
    #if os(iOS)
    @available(*, deprecated)
    func createCacheDirPath(forType type: CacheType = .walkTest, withName name: String = Date().stringWithFormat("yyyyMMdd_HHmmssSSS")) -> URL? {
        if let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let userId = SessionManager.shared.userId {
            
            let dir = cacheDir.appendingPathComponent(type.rawValue).appendingPathComponent(userId).appendingPathComponent(name)
            var isDir : ObjCBool = false
            if !FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) || !isDir.boolValue {
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
                } catch {
                    return nil
                }
            }
            try? FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: dir.path)
            return dir
        }
        return nil
    }
    
    @available(*, deprecated)
    func getParentCacheDirPath(forType type: CacheType = .walkTest) -> URL? {
        if let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let userId = SessionManager.shared.userId {
            
            let dir = cacheDir.appendingPathComponent(type.rawValue).appendingPathComponent(userId)
            var isDir : ObjCBool = false
            if !FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) || !isDir.boolValue {
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
                } catch {
                    return nil
                }
            }
            try? FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: dir.path)
            return dir
        }
        return nil
    }
    
    @available(*, deprecated)
    func getZipContents(forType type: CacheType) -> [URL]? {
        guard let parentDirectory = getParentCacheDirPath(forType: type) else {
            return nil
        }
        
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(at: parentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return contents.compactMap({ (url) -> URL? in
                if url.pathExtension != "zip" {
                    return nil
                }
                return url
            })
        } catch {
            return nil
        }
    }
    
    #endif
    
    func deleteCache(atURL url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            VError("%@", error.localizedDescription)
        }
    }
    
}
