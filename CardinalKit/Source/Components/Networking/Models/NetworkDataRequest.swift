//
//  NetworkDataRequest.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import RealmSwift

enum NetworkDataRequestError: Error {
    case packageDoesNotExist
}

enum NetworkDataRequestStatus {
    case pending
    case processing
    case completed
}

class NetworkDataRequest: Object {
    
    @objc dynamic var id = -1
    
    @objc dynamic var fileName: String? //name of file that contains Data 
    
    @objc dynamic var fileType: String? //walk test data, etc. Used to decide endpoint
    
    @objc dynamic var createdAt: Date?
    
    @objc dynamic var sentOn: Date?
    
    @objc dynamic var processing: Bool = false
    
    @objc dynamic var lastAttempt: Date?
    
    @objc dynamic var attempts: Int = 0
    
    fileprivate static let creationMutex = NSLock();
    
    var status: NetworkDataRequestStatus {
        if sentOn != nil { return .completed}
        if processing { return .processing }
        return .pending
    }
    
    var package: Package? {
        guard let fileName = fileName, let fileType = fileType, let type = PackageType(rawValue: fileType) else {
            return nil
        }
        
        return Package(fileName, type: type)
    }
    
    var type: PackageType? {
        return package?.type
    }
    
    class func nextId() throws -> Int {
        let realm = try Realm()
        let currentObjectCount = realm.objects(NetworkDataRequest.self).count
        return currentObjectCount + 1
    }
    
    class func send(_ package: Package) throws {
        guard package.hasData() else{
            throw NetworkDataRequestError.packageDoesNotExist
        }
        
        creationMutex.lock()
        let request = try findOrCreateNetworkRequest(package)
        try request.perform()
        creationMutex.unlock()
    }
    
    //NOTE: not thread safe, see send(:) function for thread-safe adaptation.
    class func findOrCreateNetworkRequest(_ request: Package) throws -> NetworkDataRequest {
        
        if let oldRequest = try findNetworkRequest(request) {
            return oldRequest
        }
        
        let newRequest = NetworkDataRequest()
        newRequest.id = try NetworkDataRequest.nextId()
        newRequest.createdAt = Date()
        newRequest.fileName = request.fileName
        newRequest.fileType = request.type.rawValue
        newRequest.sentOn = nil
        newRequest.processing = false
        newRequest.attempts = 0
        
        let realm = try Realm()
        try realm.write {
            realm.add(newRequest, update: .all)
        }
        
        return newRequest
    }
    
    class func findNetworkRequest(_ request: Package) throws -> NetworkDataRequest? {
        let realm = try Realm()
        let matches = realm.objects(NetworkDataRequest.self).filter("fileType == %@ and fileName == %@", request.type.rawValue, request.fileName)
        if !matches.isEmpty {
            assert(matches.count == 1, "NetworkDataRequest.findNetworkRequest - database inconsistency")
            return matches.first
        }
        
        return nil
    }
    
    class func findNetworkRequest(_ task: URLSessionTask) -> NetworkDataRequest? {
        guard let requestId = task.taskDescription else {
            return nil
        }
        
        let realm = try? Realm()
        let matches = realm?.objects(NetworkDataRequest.self).filter("id == \(requestId)")
        if let matches = matches, !matches.isEmpty {
            assert(matches.count == 1, "NetworkDataRequest.findNetworkRequest - database inconsistency")
            return matches.first
        }
        
        return nil
    }
    
    override var description: String {
        return "Task #\(id) : \(fileName ?? "(no fileName)") \(fileType ?? "(no fileType)") \(sentOn?.ISOStringFromDate() ?? "(never delivered)") \(processing)"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension NetworkDataRequest {
    
    func perform() throws {
        guard shouldPerform() else {
            return
        }
        
        VLog("Performing task %@", self.description)
        
        guard let package = package else {
            throw NetworkDataRequestError.packageDoesNotExist
        }
        
        let store = try package.store()
            
        if let customDelegate = CKApp.instance.options.networkDeliveryDelegate {
            // if the user has a custom send function, use it
            customDelegate.send(file: store, package: package) { [weak self] (success) in
                if (success) {
                    self?.complete()
                } else {
                    self?.fail()
                }
            }
            try markAsProcessing() //mark request as processing
        } else {
            // send file using CK network protocols
            if let endpointURL = package.routeAsURL() {
                UploadManager.shared.upload(file: store, to: endpointURL, uuid: "\(id)")
                try markAsProcessing() //mark request as processing
            }  else {
                VError("Unable to find route for network package type (%@)", package.type.rawValue)
            }
        }
            
    }
    
    func complete() {
        VLog("Marking task as completed %@", self.description)
        do {
            let realm = try Realm()
            try realm.write {
                self.sentOn = Date()
                self.processing = false
            }
            
            if let store = try package?.store() {
                CacheManager.shared.deleteCache(atURL: store)
            }
        } catch {
            VError("%@", error.localizedDescription)
        }
    }
    
    func fail() {
        VLog("Marking task as failed %@", self.description)
        do {
            let realm = try Realm()
            try realm.write {
                self.processing = false
            }
        } catch {
            VError("%@", error.localizedDescription)
        }
    }
    
    func mark(_ statusCode: Int) {
        VLog("Marking task with statusCode %@", self.description, statusCode)
        if (200 ... 299).contains(statusCode) {
            complete()
        } else {
            fail()
        }
    }
}

extension NetworkDataRequest {

    fileprivate func shouldPerform() -> Bool {
        guard CKApp.instance.options.networkDeliveryDelegate != nil || package?.route() != nil else {
            return false //package has no endpoint
        }
        
        let threshold = Date().addingTimeInterval(-60*5) //3 mins
        guard let lastAttempt = lastAttempt else {
            return true
        }
        
        return threshold > lastAttempt //let there be 3 mins between requests
    }
    
    fileprivate func markAsProcessing() throws {
        let realm = try Realm()
        try realm.write {
            self.lastAttempt = Date()
            self.attempts += 1
            self.processing = true
        }
    }
    
}
