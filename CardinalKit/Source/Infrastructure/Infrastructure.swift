//
//  Infrastructure.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 17/04/22.
//

import Foundation


// Infrastructure layer of DDD architecture
/// This layer will be the layer that accesses external services such as database, messaging systems and email services.

internal class Infrastructure {
    // Managers
    // Responsible for handling all data and requests regarding healthkit data
    var healthKitManager:HealthKitManager
    // Permissions
    // In charge of managing the necessary permissions to manipulate healthkit data (implemented in the application layer)
    var healthPermissionProvider:Healthpermissions
    // OpenMHealthSerializer
    // in charge of transforming healthkit data into an openMhealth format
    var mhSerializer:OpenMHSerializer
    
    
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
    
    // Prompt user for healthkit permissions
    func getHealthPermission(completion: @escaping (Result<Bool, Error>) -> Void){
       healthPermissionProvider.getHealthPermissions(completion: completion)
    }
    
    // Ask the user for clinical permissions
    func getClinicalPermission(completion: @escaping (Result<Bool, Error>) -> Void){
       healthPermissionProvider.getRecordsPermissions(completion: completion)
    }
    
    // start healthkit data collection in the background
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
    
    // get data from healthkit on a specific date
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
    
    //collect all clinical data
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
    
    // function called when new data is received from healthkit
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
    
    // function called when a new clinical data is received
    func onClinicalDataCollected(data: [HKClinicalRecord]){
        for sample in data {
            guard let resource = sample.fhirResource else { continue }
            let data = resource.data
            let identifier = resource.resourceType.rawValue + "-" + resource.identifier
            CreateAndPerformPackage(type: .clinicalData, data: data, identifier: identifier)
            
        }
    }
    
    /**
     to send data from healthkit to the external database we use the package model that is first saved in a local database,
     This function creates the package and saves it to then try to send it to the external database.
     
     - Parameter Type: type of package that is required to be sent
     PackageType:
         case hkdata = "HKDATA"
         case metricsData = "HKDATA_METRICS"
         case clinicalData = "HKCLINICAL"
     
     - Parameter data: the data to send
     - Parameter identifier: unique package identifier
     */
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
