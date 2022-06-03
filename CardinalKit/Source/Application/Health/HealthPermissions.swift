//
//  HealthPermissions.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol PermissionsRequestProtocol{
    var permissionsGranted:Bool{get}
    func getPermissions(completion:@escaping (Result<Bool,Error>) -> Void)
}

class Healthpermissions{
    public private(set) var permissionsGranted: Bool = false
    private var types:Set<HKSampleType>
    lazy var healthStore: HKHealthStore = HKHealthStore()
    
    init(){
        types = Set([])
    }
    
    public func configure(types: Set<HKSampleType>){
        self.types = types
    }
}

extension Healthpermissions:PermissionsRequestProtocol{
    func getPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() && SessionManager.shared.userId != nil else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Health data is not available on this device."])
            completion(.failure(error))
            return
        }
        healthStore.requestAuthorization(toShare: nil, read: types) {
            success, error in
            self.permissionsGranted = success
            completion(.success(success))
        }
    }
}
