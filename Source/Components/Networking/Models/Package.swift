//
//  Package.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

enum PackageType: String {
    case sensorData = "SENSOR_DATA"
    case snapshot = "SNAPSHOT"
    case hkdata = "HKDATA"
    
    static let debuggable: [PackageType] = [.sensorData, .hkdata]
    
    var description: String {
        switch self {
        case .sensorData:
            return "6MWT and Open Walk"
        case .snapshot:
            return "Filesystem snapshot reports"
        case .hkdata:
            return "Dump of tracked data from healthkit"
        }
    }
}

enum PackageError: Error {
    case unableToResolveStore
}

class Package: NSObject {
    
    let fileName: String
    let type: PackageType
    
    func store() throws -> URL {
        guard let store = CacheManager.shared.getPackageStore(fileName: fileName, fileType: type) else {
            throw PackageError.unableToResolveStore
        }
        return store
    }
    
    init(_ fileName: String, type: PackageType) {
        self.fileName = fileName
        self.type = type
    }
    
    convenience init(_ fileName: String, type: PackageType, data: Data) throws {
        self.init(fileName, type: type)
        try self.write(data)
    }
    
    init(_ url: URL, type: PackageType) {
        self.fileName = Package.id(url)
        self.type = type
    }
    
    func hasData() -> Bool {
        guard let store = try? store() else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: store.path)
    }
    
    func write(_ data: Data) throws {
        let store = try self.store()
        try data.write(to: store, options: .completeFileProtectionUntilFirstUserAuthentication)
    }
    
    class func id(_ url: URL) -> String {
        return url.lastPathComponent
    }
    
    override var description: String {
        return "\(fileName) : \(type)"
    }
    
}

extension Package {

    /*func route() -> APIRoute {
        return APIRoute.route(for: self.type)
    }*/
    
}

