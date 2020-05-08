//
//  HealthKitCollector.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 1/20/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit

enum HealthKitDataRange: String {
    case day = "Daily"
    case week = "Weekly"
    case month = "Monthly"
}

class HealthKitCollector {
    
    static let shared = HealthKitCollector()
    
    var isCollectionRunning: Bool = false
    var isBulkCollectionRunning: Bool = false
    
    init() {
        
    }
    
    func collectData(forDay day: Date, withRange rangeOptions: HealthKitDataRange = .day, bulk: Bool = false, onCompletion: @escaping ([HealthKitData]) -> Void) {
        
        guard !isCollectionRunning else {
            return
        }
        
        isCollectionRunning = true
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        
        let range = getRange(day, rangeOptions)
        let predicate = HKQuery.predicateForSamples(withStart: range.startRange, end: range.endRange, options: .strictEndDate)
        
        var operations = [Operation]()
        let doneOperation = Operation()
        
        let stepsOperation = CumulativeCollector(withPredicate: predicate, willCollect: .steps)
        doneOperation.addDependency(stepsOperation)
        operations.append(stepsOperation)
        
        let distanceOperation = CumulativeCollector(withPredicate: predicate, willCollect: .distance)
        doneOperation.addDependency(distanceOperation)
        operations.append(distanceOperation)
        
        let flightsOperation = CumulativeCollector(withPredicate: predicate, willCollect: .flightsClimbed)
        doneOperation.addDependency(flightsOperation)
        operations.append(flightsOperation)
        
        doneOperation.completionBlock = { [weak self] in
            
            //append all of the data that we collected into one array
            var healthKitData = [HealthKitData]()
            healthKitData.append(contentsOf: stepsOperation.healthKitData)
            healthKitData.append(contentsOf: distanceOperation.healthKitData)
            healthKitData.append(contentsOf: flightsOperation.healthKitData)
            
            //get that array and convert it into a map where every key is the source of where the data was collected (i.e. Phone vs Watch).
            let filteredHkData = healthKitData.grouped(by: { (hkData) -> String in
                return hkData.source
            })
            
            //go through our map, source by souce.
            var resultData = [HealthKitData]()
            filteredHkData.keys.forEach({ (key) in
                
                //get all the elements for a specific source (Phone vs Watch)
                if let results = filteredHkData[key] {
                    
                    //store all of the appended results for said source
                    let sourceResults = HealthKitData()
                    sourceResults.store(date: day)
                    sourceResults.passiveWhenCollected = !bulk // TODO, atm always passive but can change
                    sourceResults.source = key
                    
                    results.forEach({ (singleSourceHkData) in //for each result reported for this source
                        
                        //create a single object for this source with all of the data that we collected appended
                        
                        if singleSourceHkData.MSWS >  sourceResults.MSWS {
                            
                            sourceResults.MSWS = singleSourceHkData.MSWS
                        }
                        
                        if singleSourceHkData.steps >  sourceResults.steps {
                            
                            sourceResults.steps = singleSourceHkData.steps
                        }
                        
                        if singleSourceHkData.flightsClimbed >  sourceResults.flightsClimbed {
                            
                            sourceResults.flightsClimbed = singleSourceHkData.flightsClimbed
                        }
                        
                        if singleSourceHkData.distance >  sourceResults.distance {
                            
                            sourceResults.distance = singleSourceHkData.distance
                        }
                        
                    })
                    
                    resultData.append(sourceResults)
                    
                }
                
            })
            
            self?.isCollectionRunning = false
            DispatchQueue.main.async {
                onCompletion(resultData)
            }
        }
        
        operations.append(doneOperation)
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    func collectStrictRangeDataRetroactively(fromDate date: Date, onCompletion: @escaping ([HealthKitData]) -> Void) {
        
        guard !isBulkCollectionRunning else {
            onCompletion([HealthKitData]())
            return
        }
        
        isBulkCollectionRunning = true
        
        self.collectBulkData(startingFrom: date) { [weak self] results in
            
            self?.isBulkCollectionRunning = false
            onCompletion(results)
        }
        
    }

}

extension HealthKitCollector {
    
    fileprivate func collectBulkData(startingFrom day: Date, _ onCompletion: @escaping ([HealthKitData]) -> Void) {
        
        let semaphore = DispatchSemaphore(value: 1)
        
        var results = [HealthKitData]()
        
        let interval = day.daysTo(Date())
        var collectionCalls = 0
        for i in 0 ... interval {
            
            guard let currentDay = day.dayByAdding(i) else {
                continue
            }
            
            collectionCalls += 1
            //not using the singleton to let each operation run in its own queue
            HealthKitCollector().collectData(forDay: currentDay, bulk: true) { (dayResults: [HealthKitData]) in
                
                semaphore.wait()  // requesting results resource
                
                dayResults.forEach({ (result) in //we can get multiple results for a day because they may come from different sources (Apple vs Watch)
                    if !results.contains(result) {
                        results.append(result)
                    }
                })
                
                collectionCalls -= 1
                
                semaphore.signal()  // releasing results resource
                
                if collectionCalls == 0 {
                    onCompletion(results)
                }
            }
            
        }
        
    }
    
    fileprivate func getRange(_ day: Date, _ options: HealthKitDataRange) -> (startRange: Date?,endRange: Date?) {
        switch options {
        case .day:
            return (startRange: day.startOfDay, endRange: day.endOfDay)
        case .week:
            return (startRange: day.dayByAdding(-7), endRange: day.endOfDay)
        case .month:
            return (startRange: day.startOfMonth(), endRange: day.endOfMonth())
        }
    }
    
}

//formerly under SyncManager
import RealmSwift
import ObjectMapper
extension HealthKitCollector {
    
    //TODO: (delete) running the old data collection solution as a baseline to compare new values
    @available(*, deprecated)
    func collectAndSendForYesterday(onCompletion: @escaping ()->Void) {
        collectData(forDay: Date().dayByAdding(-1)!) { [weak self] (data) in
            guard !data.isEmpty else {
                onCompletion()
                return
            }
            
            self?.send(data, onCompletion)
        }
    }
    
    @available(*, deprecated)
    func collectAndSendSinceStartOfDay(onCompletion: @escaping ()->Void) {
        
        collectStrictRangeDataRetroactively(fromDate: Date().startOfDay) { [weak self] (data) in
            guard !data.isEmpty else {
                onCompletion()
                return
            }
            
            self?.send(data, onCompletion)
        }
    }
    
    @available(*, deprecated)
    func collectAndSendRetroactively(onCompletion: @escaping ()->Void) {
        
        let syncDate = (UserDefaults.standard.object(forKey: Constants.UserDefaults.HKStartDate) as? Date) ?? Date().dayByAdding(-1) ?? Date()
        collectStrictRangeDataRetroactively(fromDate: syncDate) { [weak self] (data) in
            guard !data.isEmpty else {
                onCompletion()
                return
            }
            
            self?.send(data, onCompletion)
        }
    }
    
    @available(*, deprecated)
    fileprivate func send(_ data: [HealthKitData], _ onCompletion: @escaping ()->Void) {
        
        let realm = try! Realm()
        
        if let lastSentPayload = realm.objects(HealthKitData.self).last,
            lastSentPayload == data.first {
            VLog("[HealthKitCollector] cummulative data already up-to-date")
            //don't send the same thing again
            //we can get here if the phone tries to sync data but hasn't moved at all since the last time it synced. This patient needs to get up!
            onCompletion()
            return
        }
        
        // let collectedData = Mapper().toJSONArray(data)
        // let payload: [String:Any] = ["daysData": collectedData]
        
        VLog("[HealthKitCollector] attempting to encode and send")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let collectedData = try encoder.encode(["payload": data])
            
            let packageName = UUID().uuidString
            let package = try Package(packageName, type: .hkdataAggregate, data: collectedData)
            try NetworkDataRequest.send(package)
            
            if let entry = data.first {
                
                let dataQueue = realm.objects(HealthKitData.self)
                try! realm.write {
                    realm.delete(dataQueue)
                    realm.add(entry, update: .all)
                }
            }
            
            onCompletion()
        } catch {
            VError("Unable to process package %@", error.localizedDescription)
            onCompletion()
        }
        
    }
    
}
