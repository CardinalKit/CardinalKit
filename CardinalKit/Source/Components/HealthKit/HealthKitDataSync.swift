//
//  HealthKitDataSync.swift
//  AstraZeneca
//
//  Created by Vineeth Gangaram on 12/11/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit
//import RealmSwift

//class HealthKitDataUploads: Object {
//    @objc dynamic var dataType: String = ""
//    @objc dynamic var lastSyncDate: Date = Date()
//    @objc dynamic var device: String = ""
//}

class HealthKitDataSync {
    
    static let shared = HealthKitDataSync()
    fileprivate let maxRetroactiveDays = 1 //day
    fileprivate var semaphoreDict = [String:NSLock]() //settled for lock since one max
    
    func collectAndUploadData(forType type: HKSampleType,fromDate startDate: Date? = nil, onCompletion: (() -> Void)?) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        getSources(forType: type) { [weak self] (sources) in
            defer { dispatchGroup.leave() }
            
            VLog("Got sources for type %@", sources.count, type.identifier)
            for source in sources {
                dispatchGroup.enter()
                
                let sourceRevision = HKSourceRevision(source: source, version: HKSourceRevisionAnyVersion)
                
                self?.collectData(forType: type, sourceRevision,fromDate: startDate) { [weak self] resultData in
                    VLog("Collected data for type and source %@", type.identifier, sourceRevision.source.key)
                    if let lastSyncDate = resultData.last?.startDate {
                        self?.setLastSyncDate(forType: type, forSource: sourceRevision, date: lastSyncDate)
                        
                        //let tag = "hkdata_\(type.identifier)_\(sourceRevision.source.key)_\(lastSyncDate.ISOStringFromDate())
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
    
    fileprivate func collectData(forType type: HKSampleType, _ sourceRevision: HKSourceRevision,fromDate startDate: Date? = nil, onCompletion: @escaping (([HKSample])->Void)) {
        var latestSync = getLastSyncDate(forType: type, forSource: sourceRevision)
        let dateFormatter = DateFormatter()
        if startDate != nil {
            latestSync=startDate!
        }
        
        self.queryHealthStore(forType: type, forSource: sourceRevision, fromDate: latestSync) { (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            
            if let error = error {
                VError("%@", error.localizedDescription)
            }
            
            guard let results = results, !results.isEmpty else {
                onCompletion([HKSample]())
                return
            }
            
            onCompletion(results)
        }
        
    }
          
    fileprivate func getSources(forType type: HKSampleType, onCompletion: @escaping ((Set<HKSource>)->Void)) {
        
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
    
//    fileprivate func getLastSyncItem(forType type: HKSampleType, _ sourceRevision: HKSourceRevision) ->
    // Results<HealthKitDataUploads>
//    String
//    {
//        return "Func TODO"
//        let realm = try! Realm()
//        let syncMetadataQuery = NSCompoundPredicate(
//            andPredicateWithSubpredicates: [
//                NSPredicate(format: "dataType = '\(type.identifier)'"),
//                NSPredicate(format: "device = '\(getSourceRevisionKey(source: sourceRevision))'")
//            ])
//
//        let result = realm.objects(HealthKitDataUploads.self).filter(syncMetadataQuery)
//        assert(result.count <= 1, "There should only be at most one sync date per type")
//
//        if result.count == 0 {
//            let metadata = HealthKitDataUploads()
//            metadata.dataType = type.identifier
//            metadata.device = getSourceRevisionKey(source: sourceRevision)
//
//            if let startDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.HKStartDate) as? Date {
//                metadata.lastSyncDate = startDate
//            } else {
//                metadata.lastSyncDate = Date().dayByAdding(-maxRetroactiveDays)! //a day ago
//            }
//
//            try! realm.write {
//                realm.add(metadata)
//            }
//        }
//
//        return result
//    }
    
    // maybe throw a default date here?
    fileprivate func getLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision) -> Date {
        if let lastSyncDate : Date = readValue(forKey: getKey(forType: type, forSource: sourceRevision)){
            return lastSyncDate
        }
        else{
            return Date().dayByAdding(-maxRetroactiveDays)!
        }
        
    //    let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
//        if let lastSyncItem = lastSyncMetadata.first {
////            return lastSyncItem.lastSyncDate
//            return Date()
//        }
        
        // No sync for this type found, grab all data for type starting from from one day ago
        // return Date().dayByAdding(-maxRetroactiveDays)! // Q: what date should we put?
    }
    
    fileprivate func setLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, date: Date) {
        let lastSyncDate : Date? = readValue(forKey: getKey(forType: type, forSource: sourceRevision))
        
        if lastSyncDate != date {
            saveValue(forKey: getKey(forType: type, forSource: sourceRevision), value: date)
        }
        
//        let realm = try! Realm()
//        let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
//        if let metadata = lastSyncMetadata.first, metadata.lastSyncDate != date {
//            try! realm.write {
//                metadata.lastSyncDate = date
//            }
//        }
    }
        private func getKey(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision) -> String{
            return "\(Constants.Sync.syncKey).\(type.identifier).\(getSourceRevisionKey(source: sourceRevision))"
        }
        private func saveValue(forKey key: String, value: Any) {
            UserDefaults.standard.set(value, forKey: key)
        }
        private func readValue<T>(forKey key: String) -> T? {
            return UserDefaults.standard.value(forKey: key) as? T
        }
        private func removeValue(forKey key: String){
            UserDefaults.standard.removeObject(forKey: key)
        }
    
    fileprivate func queryHealthStore(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, fromDate startDate: Date, queryHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate.addingTimeInterval(1), end: nil , options: .strictStartDate)
        
        let sourcePredicate = HKQuery.predicateForObjects(from: [sourceRevision])
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            queryHandler(query, results, error)
        }
        
        HealthKitManager.shared.healthStore.execute(query) // run something when finished
    }
    
    fileprivate func send(data: [HKSample]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        var samplesArray = [[String: Any]]()
        
        
        //Transform HKSampleData to mHealthFormat
        let serializer = OMHSerializer()
        
        do{
        
            try samplesArray = data.map({
                let sampleInJsonString = try serializer.json(for: $0)
                let sampleInData = Data(sampleInJsonString.utf8)
                let sampleInObject = try JSONSerialization.jsonObject(with: sampleInData, options: []) as? [String: Any]
                
                return sampleInObject!
            })
            let packageName = getPackageName(for: data)
            var index=0
            for sample in samplesArray {
                let sampleToJson = try JSONSerialization.data(withJSONObject: sample, options: [])
                do {
                    let internalName = packageName!+"\(index)"
                    index = index+1
                   let package = try Package(internalName, type: .hkdata, data: sampleToJson)
                    print("call send -----------")
                   try NetworkDataRequest.send(package)
                } catch {
                   VError("Unable to process package %{public}@", error.localizedDescription)
                }
            }
        }
        catch{
            print("Error info: \(error)")
        }
    }
    
    fileprivate func getPackageName(for data: [HKSample]) -> String? {
        let sessionEID = SessionManager.shared.userId ?? ""
        if let start = data.first?.startDate,
            let end = data.last?.startDate,
            let type = data.first?.sampleType.identifier,
            let device = data.first?.deviceKey {
            return "E\(sessionEID)_hkdata_report_\(device)_\(type)_\(start.stringWithFormat("MMdd'T'HHmm"))_\(end.stringWithFormat("MMdd'T'HHmm"))".trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
    
    fileprivate func getSourceRevisionKey(source: HKSourceRevision) -> String {
        return "\(source.productType ?? "UnknownDevice") \(source.source.key)"
    }
    
    fileprivate func getRequestKey(source: HKSourceRevision, type: HKSampleType) -> String {
        return "\(type.identifier) \(getSourceRevisionKey(source: source))"
    }
    
    
}
