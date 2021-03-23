//
//  HealthKitDataSync.swift
//  AstraZeneca
//
//  Created by Vineeth Gangaram on 12/11/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit
import RealmSwift

class HealthKitDataUploads: Object {
    @objc dynamic var dataType: String = ""
    @objc dynamic var lastSyncDate: Date = Date()
    @objc dynamic var device: String = ""
}

class HealthKitDataSync {
    
    static let shared = HealthKitDataSync()
    fileprivate let maxRetroactiveDays = 1 //day
    fileprivate var semaphoreDict = [String:NSLock]() //settled for lock since one max
    
    func collectAndUploadData(forType type: HKQuantityType, onCompletion: (() -> Void)?) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        getSources(forType: type) { [weak self] (sources) in
            defer { dispatchGroup.leave() }
            
            VLog("Got sources for type %@", sources.count, type.identifier)
            for source in sources {
                dispatchGroup.enter()
                
                let sourceRevision = HKSourceRevision(source: source, version: HKSourceRevisionAnyVersion)
                
                self?.collectData(forType: type, sourceRevision) { [weak self] resultData in
                    VLog("Collected data for type and source %@", type.identifier, sourceRevision.source.key)
                    if let lastSyncDate = resultData.last?.quantitySample?.startDate {
                        self?.setLastSyncDate(forType: type, forSource: sourceRevision, date: lastSyncDate)
                        
                        //let tag = "hkdata_\(type.identifier)_\(sourceRevision.source.key)_\(lastSyncDate.ISOStringFromDate())"
                        self?.send(data: resultData)
                        
                        VLog("Sent data for type and source %{public}@", type.identifier, sourceRevision.source.key)
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            onCompletion?()
        }
        
    }
    
}

extension HealthKitDataSync {
    
    fileprivate func collectData(forType type: HKQuantityType, _ sourceRevision: HKSourceRevision, onCompletion: @escaping (([HKSampleData])->Void)) {
        
        let latestSync = getLastSyncDate(forType: type, forSource: sourceRevision)
        
        self.queryHealthStore(forType: type, forSource: sourceRevision, fromDate: latestSync) { (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            
            if let error = error {
                VError("%@", error.localizedDescription)
            }
            
            guard let results = results as? [HKQuantitySample], !results.isEmpty else {
                onCompletion([HKSampleData]())
                return
            }
            
            let resultData = results.map({ (quantitySample) -> HKSampleData in
                return HKSampleData(sample: quantitySample)
            })
            
            
            onCompletion(resultData)
        }
        
    }
    
    fileprivate func getSources(forType type: HKQuantityType, onCompletion: @escaping ((Set<HKSource>)->Void)) {
        
        // find all sources that contain requested data type
        //TODO testing datePredicate, only look through sources that have been active in the last five days... filters out devices that are no longer in use.
        let datePredicate = HKQuery.predicateForSamples(withStart: Date().dayByAdding(-5)! , end: Date(), options: .strictStartDate)
        let query = HKSourceQuery(sampleType: type, samplePredicate: datePredicate) {
            query, sources, error in
            
            if let error = error {
                VError("%@", error.localizedDescription)
            }
            
            if let sources = sources {
                onCompletion(sources)
            } else {
                onCompletion([])
            }
            
        }
        
        HealthKitManager.shared.healthStore.execute(query)
    }
    
}

extension HealthKitDataSync {
    
    fileprivate func getLastSyncItem(forType type: HKQuantityType, _ sourceRevision: HKSourceRevision) -> Results<HealthKitDataUploads> {
        
        let realm = try! Realm()
        let syncMetadataQuery = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "dataType = '\(type.identifier)'"),
                NSPredicate(format: "device = '\(getSourceRevisionKey(source: sourceRevision))'")
            ])
        
        let result = realm.objects(HealthKitDataUploads.self).filter(syncMetadataQuery)
        assert(result.count <= 1, "There should only be at most one sync date per type")
        
        if result.count == 0 {
            let metadata = HealthKitDataUploads()
            metadata.dataType = type.identifier
            metadata.device = getSourceRevisionKey(source: sourceRevision)

            if let startDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.HKStartDate) as? Date {
                metadata.lastSyncDate = startDate
            } else {
                metadata.lastSyncDate = Date().dayByAdding(-maxRetroactiveDays)! //a day ago
            }
            
            try! realm.write {
                realm.add(metadata)
            }
        }
        
        return result
    }
    
    // maybe throw a default date here?
    fileprivate func getLastSyncDate(forType type: HKQuantityType, forSource sourceRevision: HKSourceRevision) -> Date {
        
        let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
        if let lastSyncItem = lastSyncMetadata.first {
            return lastSyncItem.lastSyncDate
        }
        
        // No sync for this type found, grab all data for type starting from from one day ago
        return Date().dayByAdding(-maxRetroactiveDays)! // Q: what date should we put?
    }
    
    fileprivate func setLastSyncDate(forType type: HKQuantityType, forSource sourceRevision: HKSourceRevision, date: Date) {
        
        let realm = try! Realm()
        let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
        if let metadata = lastSyncMetadata.first, metadata.lastSyncDate != date {
            try! realm.write {
                metadata.lastSyncDate = date
            }
        }
    }
    
    fileprivate func queryHealthStore(forType type: HKQuantityType, forSource sourceRevision: HKSourceRevision, fromDate startDate: Date, queryHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate.addingTimeInterval(1) , end: Date(), options: .strictStartDate)
        let sourcePredicate = HKQuery.predicateForObjects(from: [sourceRevision])
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            queryHandler(query, results, error)
        }
        
        HealthKitManager.shared.healthStore.execute(query) // run something when finished
    }
    
    fileprivate func send(data: [HKSampleData]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let collectedData = try? encoder.encode(["payload": data]),
            let packageName = getPackageName(for: data) {
            do {
                let package = try Package(packageName, type: .hkdata, data: collectedData)
                try NetworkDataRequest.send(package)
            } catch {
                VError("Unable to process package %{public}@", error.localizedDescription)
            }
        }
    }
    
    fileprivate func getPackageName(for data: [HKSampleData]) -> String? {
        let sessionEID = SessionManager.shared.userId ?? ""
        if let start = data.first?.quantitySample?.startDate,
            let end = data.last?.quantitySample?.startDate,
            let type = data.first?.quantitySample?.type,
            let device = data.first?.quantitySample?.source {
            return "E\(sessionEID)_hkdata_report_\(device)_\(type)_\(start.stringWithFormat("MMdd'T'HHmm"))_\(end.stringWithFormat("MMdd'T'HHmm"))".trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
    
    fileprivate func getSourceRevisionKey(source: HKSourceRevision) -> String {
        return "\(source.productType ?? "UnknownDevice") \(source.source.key)"
    }
    
    fileprivate func getRequestKey(source: HKSourceRevision, type: HKQuantityType) -> String {
        return "\(type.identifier) \(getSourceRevisionKey(source: source))"
    }
}

