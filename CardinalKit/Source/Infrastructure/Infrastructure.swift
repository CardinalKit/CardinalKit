//
//  Infrastructure.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 17/04/22.
//

import Foundation


internal class Infrastructure {
    // Managers
    var healthKitManager:HealthKitManager
    // Permissions
    var healthPermissionProvider:Healthpermissions
    // OpenMHealthSerializer
    var mhSerializer:OpenMHSerializer
    //
    
    
    init(){
        healthKitManager = HealthKitManager()
        mhSerializer = CKOpenMHSerializer()
        healthPermissionProvider = Healthpermissions()
        healthPermissionProvider.configure(types: healthKitManager.defaultTypes(), clinicalTypes: healthKitManager.healthRecordsDefaultTypes())
        _ = NetworkTracker.shared
        
    }
    
    func configure(types: Set<HKSampleType>, clinicalTypes: Set<HKSampleType>){
        healthPermissionProvider.configure(types: types, clinicalTypes: clinicalTypes)
        healthKitManager.configure(types: types, clinicalTypes: clinicalTypes)
    }
    
    func getHealthPermission(completion: @escaping (Result<Bool, Error>) -> Void){
       healthPermissionProvider.getHealthPermissions(completion: completion)
    }
    
    func getClinicalPermission(completion: @escaping (Result<Bool, Error>) -> Void){
       healthPermissionProvider.getRecordsPermissions(completion: completion)
    }
    
    func startBackgroundDeliveryData(){
        healthPermissionProvider.getHealthPermissions{ result in
            switch result{
                case .success(let success):
                if success {
                    self.healthKitManager.startHealthKitCollectionInBackground(withFrequency: "")
                }
                case .failure(let error):
                 print("error \(error)")
            }
        }
    }
    
    func collectData(fromDate startDate:Date, toDate endDate: Date){
        healthPermissionProvider.getAllPermissions(){ result in
            switch result{
                case .success(let success):
                if success {
                    // TODO: Configure all types
                    self.healthKitManager.startCollectionByDayBetweenDate(fromDate: startDate, toDate: endDate)
                    self.healthKitManager.collectAndUploadClinicalTypes()
                }
                case .failure(let error):
                 print("error \(error)")
            }
        }
    }
    
    func collectClinicalData(){
        healthPermissionProvider.getAllPermissions(){ result in
            switch result{
                case .success(let success):
                if success {
                    self.healthKitManager.collectAndUploadClinicalTypes()
                }
                case .failure(let error):
                 print("error \(error)")
            }
        }
    }
    
    
    func onHealthDataColected(data:[HKSample]){
        do{
            // Transfom Data in OPENMHealth Format
            let samplesArray:[[String: Any]] = try mhSerializer.json(for: data)
            for sample in samplesArray{
               
                var identifier = "HKData"
                if let header = sample["header"] as? [String:Any],
                   let id = header["id"] as? String{
                    identifier = id
                }
                
                let sampleToData = try JSONSerialization.data(withJSONObject: sample, options: [])
                CreateAndPerformPackage(type: .hkdata, data: sampleToData, identifier: identifier)
            }
        }
        catch{
            print("Error Transform Data: \(error)")
        }
    }
    
    func onClinicalDataCollected(data: [HKClinicalRecord]){
        for sample in data {
            guard let resource = sample.fhirResource else { continue }
            let data = resource.data
            let identifier = resource.resourceType.rawValue + "-" + resource.identifier
            CreateAndPerformPackage(type: .clinicalData, data: data, identifier: identifier)
            
        }
    }
    
    private func CreateAndPerformPackage(type: PackageType, data:Data, identifier: String){
        do{
            let packageName = identifier
            let package = try Package(packageName, type: type, identifier: packageName, data: data)
            let networkObject = NetworkRequestObject.findOrCreateNetworkRequest(package)
            try networkObject.perform()
        }
        catch{
            print("[upload] ERROR " + error.localizedDescription)
        }
        
    }
}
