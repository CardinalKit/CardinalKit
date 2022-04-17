//
//  Infrastructure.swift
//  abseil
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
    
    init(){
        healthKitManager = HealthKitManager()
        mhSerializer = CKOpenMHSerializer()
        healthPermissionProvider = Healthpermissions()
        healthPermissionProvider.configure(types: Set([HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]))
    }
    
    func startBackgroundDeliveryData(){
        healthPermissionProvider.getPermissions{ result in
            switch result{
                case .success(let success):
                if success {
                    self.healthKitManager.startHealthKitCollectionInBackground(withFrequency: "", forTypes: Set([HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]))
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
                    self.healthKitManager.startCollectionByDayBetweenDate(fromDate: startDate, toDate: endDate, forTypes: Set([HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!]))
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
            if let delegate = CKApp.instance.options.networkDeliveryDelegate{
                if let authPath = CKStudyUser.shared.authCollection{
                    var index=0
                    for sample in samplesArray {
                        let internalName = "packageName"+"\(index)"
                        index = index+1
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
