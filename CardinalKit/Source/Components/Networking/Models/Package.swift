//
//  Package.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

public enum PackageType: String {
    case sensorData = "SENSOR_DATA"
    case snapshot = "SNAPSHOT"
    case hkdata = "HKDATA"
    case hkdataAggregate = "HKDATA_AGGREGATE"
    
    static let debuggable: [PackageType] = [.sensorData, .hkdata]
    
    public var description: String {
        switch self {
        case .sensorData:
            return "6MWT and Open Walk"
        case .snapshot:
            return "Filesystem snapshot reports"
        case .hkdata:
            return "Dump of tracked data from healthkit"
        case .hkdataAggregate:
            return "Aggregate summary per day"
        }
    }
}

enum PackageError: Error {
    case unableToResolveStore
}

public class Package: NSObject {
    
    public let fileName: String
    public let type: PackageType
    
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
    
    public override var description: String {
        return "\(fileName) : \(type)"
    }
    
}

extension Package {
    
    func route() -> String? {
        return CKApp.instance.options.networkRouteDelegate?.getAPIRoute(type: self.type)
    }
    
    func routeAsURL() -> URL? {
        guard let route = route() else {
            return nil
        }
        
        return URL(string: route)
    }

    /*func route() -> APIRoute {
        return APIRoute.route(for: self.type)
    }*/
    
}

