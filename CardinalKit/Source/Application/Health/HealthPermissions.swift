//
//  HealthPermissions.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/04/22.
//

import Foundation

public protocol PermissionsRequestProtocol{
    var permissionsGranted:Bool{get}
    func getHealthPermissions(completion:@escaping (Result<Bool,Error>) -> Void)
    func getRecordsPermissions(completion:@escaping (Result<Bool,Error>) -> Void)
}

class Healthpermissions{
    public private(set) var permissionsGranted: Bool = false
    private var types:Set<HKSampleType>
    private var clinicalTypes:Set<HKSampleType>
    lazy var healthStore: HKHealthStore = HKHealthStore()
    
    init(){
        types = Set([])
        clinicalTypes = Set([])
    }
    
    public func configure(types: Set<HKSampleType>, clinicalTypes: Set<HKSampleType>){
        self.types = types
        self.clinicalTypes = clinicalTypes
    }
}

extension Healthpermissions:PermissionsRequestProtocol{
    func getRecordsPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
        getPermissions(types: clinicalTypes, completion: completion)
    }
    
    func getHealthPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
        getPermissions(types: types, completion: completion)
    }
    
    func getAllPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
        let nTypes = types.union(clinicalTypes)
        getPermissions(types: nTypes, completion: completion)
    }
    
    private func getPermissions(types: Set<HKSampleType>,completion: @escaping (Result<Bool, Error>) -> Void) {
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
