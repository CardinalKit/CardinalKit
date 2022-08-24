//
//  Package.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

public enum PackageType: String {
    // TODO: implement sensorsData and other types
//    case sensorData = "SENSOR_DATA"
//    case snapshot = "SNAPSHOT"
    //    case hkdataAggregate = "HKDATA_AGGREGATE"
    
//        case .sensorData:
//            return "6MWT and Open Walk"
//        case .snapshot:
//            return "Filesystem snapshot reports"
//        case .hkdataAggregate:
//            return "Aggregate summary per day"
    case hkdata = "HKDATA"
    case metricsData = "HKDATA_METRICS"
    case clinicalData = "HKCLINICAL"
    
    static let debuggable: [PackageType] = [.hkdata]
    
    public var description: String {
        switch self {
        case .hkdata:
            return "Dump of tracked data from healthkit"
        case .metricsData:
            return "metrics data"
        case .clinicalData:
            return "Clinical Records"
        }
    }
}

enum PackageError: Error {
    case unableToResolveStore
}

public class Package: NSObject {
    
    public let fileName: String
    public let type: PackageType
    public let identifier: String
    
    func store() throws -> URL {
        guard let store = CacheManager.shared.getPackageStore(fileName: fileName, fileType: type) else {
            throw PackageError.unableToResolveStore
        }
        return store
    }
    
    init(_ fileName: String, type: PackageType, identifier:String) {
        self.fileName = fileName
        self.type = type
        self.identifier = identifier
    }
    
    convenience init(_ fileName: String, type: PackageType,identifier:String,  data: Data) throws {
        self.init(fileName, type: type, identifier: identifier)
        try self.write(data)
    }
    
    init(_ url: URL, type: PackageType, identifier:String) {
        self.fileName = Package.id(url)
        self.type = type
        self.identifier = identifier
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
