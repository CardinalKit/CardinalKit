//
//  LocalDatabaseObjects.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 7/04/22.
//


import Foundation

public struct DateLastSyncObject{
    var dataType: String = ""
    var lastSyncDate: Date = Date()
    var device: String = ""
}

//  Copied from
//  NetworkDataRequest.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

enum NetworkDataRequestError: Error {
    case packageDoesNotExist
}

enum NetworkDataRequestStatus {
    case pending
    case processing
    case completed
}

public struct NetworkRequestObject{
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
    
    
}
