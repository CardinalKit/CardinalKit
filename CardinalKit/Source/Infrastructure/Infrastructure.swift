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
    var mhSerializer:CKOpenMHSerializer
    //
    
    
    init(){
        healthKitManager = HealthKitManager()
        mhSerializer = CKOpenMHSerializer()
        healthPermissionProvider = Healthpermissions()
        healthPermissionProvider.configure(types: healthKitManager.defaultTypes())
        _ = NetworkTracker.shared
        
    }
    
    func configure(types: Set<HKSampleType>){
        healthPermissionProvider.configure(types: types)
        healthKitManager.configure(types: types)
    }
    
    func getHealthPermission(completion: @escaping (Result<Bool, Error>) -> Void){
       healthPermissionProvider.getPermissions(completion: completion)
    }
    
    func startBackgroundDeliveryData(){
        healthPermissionProvider.getPermissions{ result in
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
        healthPermissionProvider.getPermissions{ result in
            switch result{
                case .success(let success):
                if success {
                    // TODO: Configure all types
                    self.healthKitManager.startCollectionByDayBetweenDate(fromDate: startDate, toDate: endDate)
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
                let sampleToJson = try JSONSerialization.data(withJSONObject: sample, options: [])
                do {
                    // TODO: Add package name
                    let package = try Package("PackageName", type: .hkdata, identifier: "identifier", data: sampleToJson)
                    let networkObject = NetworkRequestObject.findOrCreateNetworkRequest(package)
                    try networkObject.perform()
                }
                catch{
                    VError("Unable to process package %{public}@", error.localizedDescription)
                }
                
            }
            
            
            if let delegate = CKApp.instance.options.networkDeliveryDelegate{
                if let authPath = CKStudyUser.shared.authCollection{
                    var index=0
                    for sample in samplesArray {
                        let internalName = "packageName"+"\(index)"
                        index = index+1
                        // TODO: Save data Locally and then send
                        
                        delegate.send(route: "\(authPath)\(Constants.Firebase.dataBucketHealthKit)/\(internalName)", data: sample, params: nil){ success, error in
                            print("sended")
                        }
                    }
                }
            }
        }
        catch{
            print("Error Transform Data: \(error)")
        }
        
       
        
        // Transform Data with Granola
        // Save data on locally
        // Try send data to Cloud
        
    }
    
}
