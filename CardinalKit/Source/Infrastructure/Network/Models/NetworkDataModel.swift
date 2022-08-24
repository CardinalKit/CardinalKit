//  Copied from
//  NetworkDataRequest.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//


import Foundation

public class DateLastSyncObject{
    var dataType: String
    var lastSyncDate: Date
    var device: String
    
    init(dataType:String, lastSyncDate:Date, device:String){
        self.dataType = dataType
        self.lastSyncDate = lastSyncDate
        self.device = device
    }
}

enum NetworkDataRequestError: Error {
    case packageDoesNotExist
}

enum NetworkDataRequestStatus {
    case pending
    case processing
    case completed
}

public class NetworkRequestObject{
    var id: Int = -1
    var fileName: String?
    var fileType: String?
    var createdAt: Date?
    var sentOn: Date?
    var processing: Bool = false
    var lastAttempt: Date?
    var attempts: Int = 0
    
    var status: NetworkDataRequestStatus {
        if sentOn != nil { return .completed}
        if processing { return .processing }
        return .pending
    }
    
    var package: Package? {
        guard let fileName = fileName, let fileType = fileType, let type = PackageType(rawValue: fileType) else {
            return nil
        }
        
        return Package(fileName, type: type, identifier: "\(Date())-\(fileName)")
    }
    
    var type: PackageType? {
        return package?.type
    }
    
    init(id:Int){
        self.id = id
    }
    //Create new or find Exist
    init(request: Package){
        id = nextId()
        createdAt = Date()
        fileName = request.fileName
        fileType = request.type.rawValue
        sentOn = nil
        processing = false
        attempts = 0
        Save()
    }
    
    class func findNetworkRequest(_ request: Package)  -> NetworkRequestObject? {
        let filterQuery =  String(format:"fileType == %@ and fileName == %@", request.type.rawValue, request.fileName)
        let matches = CKApp.instance.options.localDBDelegate?.getNetworkItemsByFilter(filterQuery: "fileType == '\(request.type.rawValue)' and fileName == '\(request.fileName)'" )
        if let matches = matches,
           !matches.isEmpty{
            assert(matches.count == 1, "NetworkDataRequest.findNetworkRequest - database inconsistency")
            return matches.first
        }
        return nil
    }
    
    class func findOrCreateNetworkRequest(_ request: Package)  -> NetworkRequestObject {
        
        if let oldRequest = findNetworkRequest(request) {
            return oldRequest
        }
        
        let newRequest = NetworkRequestObject(request: request)
        return newRequest
    }
    
    func nextId() -> Int{
        let currentObjects = CKApp.instance.options.localDBDelegate?.getNetworkItemsByFilter(filterQuery: nil)
        if let currentObjects = currentObjects{
            return currentObjects.count + 1
        }
        else{
            return 1
        }
    }
}

extension NetworkRequestObject {
    func perform(onCompletion: ((Bool, Error?) -> Void)? = nil) throws {
        guard shouldPerform() else{
            return
        }
        
        guard let package = package else {
            throw NetworkDataRequestError.packageDoesNotExist
        }
        
        let store = try package.store()
        
        if let deliveryDelegate = CKApp.instance.options.networkDeliveryDelegate{
            deliveryDelegate.send(file: store, package: package) { (success) in
                DispatchQueue.main.async {
                    if success {
                        self.complete()
                        onCompletion?(true, nil)
                    }
                    else{
                        self.fail()
                        onCompletion?(false, nil)
                    }
                }
            }
            try markAsProcessing()
        }
    }
    
    func complete(){
        sentOn = Date()
        processing = false
        Save()
        
        do{
            if let store = try self.package?.store() {
                CacheManager.shared.deleteCache(atURL: store)
            }
        }
        catch{
            VError("%@", error.localizedDescription)
        }
    }
    
    func fail(){
        processing = false
        Save()
    }
}

extension NetworkRequestObject{
    fileprivate func shouldPerform() -> Bool {
        guard CKApp.instance.options.networkDeliveryDelegate != nil
        else {
            return false //package has no endpoint
        }
        
        let threshold = Date().addingTimeInterval(-60*5) //3 mins
        guard let lastAttempt = lastAttempt else {
            return true
        }
        
        return threshold > lastAttempt //let there be 3 mins between requests
    }
    
    fileprivate func markAsProcessing() throws {
        lastAttempt = Date()
        attempts += 1
        processing = true
        Save()
    }
    
    fileprivate func Save(){
        CKApp.instance.options.localDBDelegate?.saveNetworkItem(item: self)
    }
}
