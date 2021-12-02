//
//  HealthKitDataSync.swift
//  AstraZeneca
//
//  Created by Vineeth Gangaram on 12/11/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit
import RealmSwift
import UIKit

class HealthKitDataUploads: Object {
    @objc dynamic var dataType: String = ""
    @objc dynamic var lastSyncDate: Date = Date()
    @objc dynamic var device: String = ""
}

class HealthKitDataSync {
    
    static let shared = HealthKitDataSync()
    fileprivate let maxRetroactiveDays = 1 //day
    fileprivate var semaphoreDict = [String:NSLock]() //settled for lock since one max
    
    func collectAndUploadData(forType type: HKSampleType,fromDate startDate: Date? = nil, onCompletion: (() -> Void)?) {
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        getSources(forType: type) { [weak self] (sources) in
            defer {
                dispatchGroup.leave()                
            }
            
            VLog("Got sources for type %@", sources.count, type.identifier)
            for source in sources {
                dispatchGroup.enter()
                
                let sourceRevision = HKSourceRevision(source: source, version: HKSourceRevisionAnyVersion)
                
                self?.collectData(forType: type, sourceRevision,fromDate: startDate) { [weak self] resultData in
                    DispatchQueue.main.async {
                        VLog("Collected data for type and source %@", type.identifier, sourceRevision.source.key)
                        if let lastSyncDate = resultData.last?.startDate {
                            self?.setLastSyncDate(forType: type, forSource: sourceRevision, date: lastSyncDate)
                            
                            //let tag = "hkdata_\(type.identifier)_\(sourceRevision.source.key)_\(lastSyncDate.ISOStringFromDate())
                            // need async
                            self?.send(data: resultData){() in
                                dispatchGroup.leave()
                            }
                            
                            VLog("Sent data for type and source %{public}@", type.identifier, sourceRevision.source.key)
                        }
                        
                        
                    }
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
        //get last sync of activity index
       updateActivityIndex()
        
        
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
    
    fileprivate func getLastSyncItem(forType type: HKSampleType, _ sourceRevision: HKSourceRevision) -> Results<HealthKitDataUploads> {
        
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
    fileprivate func getLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision) -> Date {
        
        let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
        if let lastSyncItem = lastSyncMetadata.first {
            return lastSyncItem.lastSyncDate
        }
        
        // No sync for this type found, grab all data for type starting from from one day ago
        return Date().dayByAdding(-maxRetroactiveDays)! // Q: what date should we put?
    }
    
    fileprivate func getLastSyncActivityIndex() -> Date{
        let realm = try! Realm()
        let syncMetadataQuery = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "dataType = 'activityIndex'"),
                NSPredicate(format: "device = 'general'")
            ])
        
        let result = realm.objects(HealthKitDataUploads.self).filter(syncMetadataQuery)
        assert(result.count <= 1, "There should only be at most one sync date per type")
        
        if result.count == 0 {
            let metadata = HealthKitDataUploads()
            metadata.dataType = "activityIndex"
            metadata.device = "general"

            if let startDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.HKStartDate) as? Date {
                metadata.lastSyncDate = startDate
            } else {
                metadata.lastSyncDate = Date().dayByAdding(-7)! //a day ago
            }
            
            try! realm.write {
                realm.add(metadata)
            }
        }
        if let lastSyncItem = result.first {
            return lastSyncItem.lastSyncDate
        }
        return Date().dayByAdding(-7)!
        
    }
    
    // calculate the last time the activity index was loaded and send an update if necessary
    fileprivate func updateActivityIndex(){
        // get the last time the activity index was calculated
        let latestSync = getLastSyncActivityIndex()
        let diff = Calendar.current.dateComponents([.day], from: latestSync, to: Date())
        
        if diff.day ?? 1 > 0 {
            var nDate = latestSync
            while (nDate<Date().startOfDay) {
                getActivityIndex(for: nDate.startOfDay){
                    activityIndex,date,stepCount in
                    //send
                    DispatchQueue.main.async {
                    self.sendActivityIndex(forDate: date, value: activityIndex, stepCount: stepCount)
                    }
                    
                }
                nDate = nDate.dayByAdding(1)!
            }
            
            let realm = try! Realm()
            let syncMetadataQuery = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(format: "dataType = 'activityIndex'"),
                    NSPredicate(format: "device = 'general'")
                ])
            
            let result = realm.objects(HealthKitDataUploads.self).filter(syncMetadataQuery)
            assert(result.count <= 1, "There should only be at most one sync date per type")
            
            let date = Date().startOfDay
            if let metadata = result.first,
               metadata.lastSyncDate != date {
                try! realm.write {
                    metadata.lastSyncDate = date
                }
            }
            
        }
        
    }
    
    fileprivate func getActivityIndex(for date: Date, onCompletion: @escaping (Double,Date,Double)->Void){
        var stepsDict:[Date:Double] = [:]
        let startDate = date.dayByAdding(-7)!.startOfDay
        let type = HKSampleType.quantityType(forIdentifier: .stepCount)
        var interval = DateComponents()
        interval.day = 1
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: date.endOfDay, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: date, intervalComponents:interval)
        query.initialResultsHandler = { query, results, error in
            if let myResults = results{
                myResults.enumerateStatistics(from: startDate, to: date) {
                    statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        stepsDict[date]=steps
                    }
                }
            }
            if stepsDict.count>0{
                var nDate = startDate
                var stepsArray:[Double]=[]
                //organice by dates
                while nDate<=date {
                    stepsArray.append(stepsDict[nDate] ?? 0.0)
                    nDate=nDate.dayByAdding(1)!
                }
                let k=0.25
                var emaArray = [stepsArray[0]]
                for i in 1...(stepsArray.count-1) {
                    emaArray.append(stepsArray[i]*k+emaArray[i-1]*(1-k))
                }
                let activityIndex = emaArray[emaArray.count-1]
                onCompletion(activityIndex,date,stepsArray[stepsArray.count-1])
            }
            else{
                onCompletion(0.0,date,0.0)
            }
        }
        HealthKitManager.shared.healthStore.execute(query)
    }
    
    fileprivate func setLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, date: Date) {
        
        let realm = try! Realm()
        let lastSyncMetadata = getLastSyncItem(forType: type, sourceRevision)
        if let metadata = lastSyncMetadata.first, metadata.lastSyncDate != date {
            try! realm.write {
                metadata.lastSyncDate = date
            }
        }
    }
    
    fileprivate func queryHealthStore(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, fromDate startDate: Date, queryHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate.addingTimeInterval(1) , end: Date(), options: .strictStartDate)
        let sourcePredicate = HKQuery.predicateForObjects(from: [sourceRevision])
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
        
//        if let quantityType = type as? HKQuantityType{
//            let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate){
//                (query: HKStatisticsQuery, results: HKStatistics?, error: Error?) in
//                let value = results?.sumQuantity()
//
////                queryHandler(query, results, error)
//            }
//            HealthKitManager.shared.healthStore.execute(query) // run something when finished
//        }
//        else{
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1000, sortDescriptors: [sortDescriptor]) {
            (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            queryHandler(query, results, error)
        }
        
        HealthKitManager.shared.healthStore.execute(query) // run something when finished
//        }
        
        
    }
    
    fileprivate func sendActivityIndex(forDate date: Date,value: Double, stepCount:Double){
        let dictionary=["date":date.shortStringFromDate(),"activityindex":String(value),"stepCount":String(stepCount)]
        do{
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let package = try Package("metrics"+date.shortStringFromDate(), type: .metricsData, data: data)
            try NetworkDataRequest.send(package)
        }
        catch{
            print("error send activity index")
        }
    }
    
    fileprivate func send(data: [HKSample], onCompletion: (() -> Void)? = nil) {
        if data.count>999{
            do {
                let dataType = String(describing: data[0].sampleType)
                let packageName = "dataUpperThan1000 \(dataType)"
                let jsonObject = ["dataType": dataType]
                let sampleToJson = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                let package = try Package(packageName, type: .hkdata, data: sampleToJson)
                try NetworkDataRequest.send(package) { (success,error) in}
            } catch {
               VError("Unable to process package %{public}@", error.localizedDescription)
            }
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let dispatchGroup = DispatchGroup()
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
            let newData = JoinData(data: samplesArray)
            let packageName = getPackageName(for: data)
            var index=0
            for sample in newData {
                dispatchGroup.enter()
                let sampleToJson = try JSONSerialization.data(withJSONObject: sample, options: [])
                do {
                    let internalName = packageName!+"\(index)"
                    index = index+1
                   let package = try Package(internalName, type: .hkdata, data: sampleToJson)
                    // async
                    try NetworkDataRequest.send(package) { (success,error) in
                        dispatchGroup.leave()
                    }
                } catch {
                   VError("Unable to process package %{public}@", error.localizedDescription)
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main) {
                onCompletion?()
            }
        }
        catch{
            print("Error info: \(error)")
        }
    }
    
    fileprivate func JoinData(data: [[String: Any]])->[[String: Any]]{
        
        let firstElement = data.first
        if let element = firstElement,
           let body = element["body"] as? [String: Any]
        {
//            if is quantity
            if let quantityType = body["quantity_type"] as? String{
                switch(quantityType){
                case "HKQuantityTypeIdentifierStepCount":
                    return joinDataStepCount(data: data)
                case "HKQuantityTypeIdentifierActiveEnergyBurned":
                    return joinDataEnergyBurned(data: data)
                default:
                    return data
                }

            }

        }
        
        return data
        
    }
    
    private func joinDataEnergyBurned(data: [[String:Any]])->[[String:Any]]{
        var finalData = [[String: Any]]()
        var datesDictionary = [Date:[String:Any]]()
        var firstElement = data.first!
        var body = firstElement["body"] as! [String: Any]
        if var kcalBurned = body["kcal_burned"] as? [String:Any]{
            for element in data {
                if let nBody = element["body"] as? [String:Any],
                   let kcal = nBody["kcal_burned"] as? [String:Any],
                   let kcalValue = kcal["value"] as? Int {
                    if let time_frame = nBody["effective_time_frame"] as? [String:Any],
                       let dateStr = time_frame["date_time"] as? String{
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
                        let date = dateFormatter.date(from: dateStr)!
                        let onlyDate = removeTimeStamp(fromDate: date)
                        var finalKcalValue = kcalValue
                        if let dateKcalValue = datesDictionary[onlyDate]{
                            finalKcalValue+=dateKcalValue["count"] as! Int
                        }
                        else{
                            datesDictionary[onlyDate]=[String:Any]()
                            datesDictionary[onlyDate]?["date"] = dateStr
                        }
                        datesDictionary[onlyDate]?["count"]=finalKcalValue
                    }
                }
            }
            for dateElement in datesDictionary{
                kcalBurned["value"] = dateElement.value["count"]
                body["kcal_burned"] = kcalBurned
                body["effective_time_frame"] = ["date_time":dateElement.value["date"]]
                firstElement["body"]=body
                finalData.append(firstElement)
            }
            return finalData
        }
        else{
            return data
        }
    }
    
    private func joinDataStepCount(data: [[String: Any]])->[[String: Any]]{
        var finalData = [[String: Any]]()
        var datesDictionary = [Date:[String:Any]]()
        var firstElement = data.first!
        var body = firstElement["body"] as! [String: Any]
        
        for element in data {
            if let nBody = element["body"] as? [String:Any],
               let count = nBody["step_count"] as? Int{
                if let time_frame = nBody["effective_time_frame"] as? [String:Any],
                   let dateStr = time_frame["date_time"] as? String{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
                    let date = dateFormatter.date(from: dateStr)!
                    let onlyDate = removeTimeStamp(fromDate: date)
                    var finalStepCount = count
                    if let dateStepCount = datesDictionary[onlyDate]{
                        finalStepCount+=dateStepCount["count"] as! Int
                    }
                    else{
                        datesDictionary[onlyDate]=[String:Any]()
                        datesDictionary[onlyDate]?["date"] = dateStr
                    }
                    datesDictionary[onlyDate]?["count"]=finalStepCount
                }
            }
        }
        for dateElement in datesDictionary{
            body["step_count"] = dateElement.value["count"]
            body["effective_time_frame"] = ["date_time":dateElement.value["date"]]
            firstElement["body"]=body
            finalData.append(firstElement)
        }
        return finalData
    }
    
    private func removeTimeStamp(fromDate: Date) -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
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
