//
//  CumulativeCollector.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 1/27/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit

class CumulativeCollector: DAOperation {
    
    lazy var healthStore: HKHealthStore = HKHealthStore()
    let queryPredicate: NSPredicate?
    let collectionMetric: HealthKitDataModel?
    
    var healthKitData = [HealthKitData]()
    
    init(withPredicate predicate: NSPredicate?, willCollect: HealthKitDataModel?) {
        self.queryPredicate = predicate
        self.collectionMetric = willCollect
    }
    
    override func main() {
        guard !isCancelled, let queryPredicate = queryPredicate, let queryMetric = getQueryMetric() else {
                finish(true)
                return
        }
        
        executing(true)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: queryMetric, predicate: queryPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            
            self?.didReceiveQueryResult(query, results, error)
        }
        
        self.healthStore.execute(query)
    }
    
    func didReceiveQueryResult(_ query: HKSampleQuery, _ results: [HKSample]?, _ error: Error?) {
        guard let results = results as? [HKQuantitySample], error == nil else { // there was an error reading from healthKit
            self.finishExecution()
            return
        }
        
        let groupedResults = results.grouped { (sample) -> String in
            return sample.device?.getKey(appendSource: sample.sourceRevision.source) ?? "Unknown"
        }
        
        groupedResults.keys.forEach { (key) in
            
            if let results = groupedResults[key] {
                
                let calculatedSum = sum(results)
                calculatedSum.forEach({ (metric, value) in
                    let healthData = HealthKitData()
                    healthData.set(value: value, usingType: metric)
                    healthData.source = key
                    
                    healthKitData.append(healthData)
                })
                
            }
            
        }
        
        self.finishExecution()
    }
    
}

//Processing Methods
extension CumulativeCollector {
    
    fileprivate func sum(_ daySample: [HKQuantitySample]) -> [HealthKitDataModel:Double] {
        
        var result = [HealthKitDataModel:Double]()
        
        if let metric = collectionMetric {
            
            switch metric {
            case .maxNonStopSteps:
                fallthrough
            case .totalSteps:
                let sum = stepsSum(daySample)
                if !sum.isEmpty {
                    result.append(sum)
                }
            case .totalFlights:
                fallthrough
            case .distanceWalked:
                if let sum = cummulativeSum(daySample) {
                    result[metric] = sum
                }
            }
            
        }
        
        return result
    }
    
    func cummulativeSum(_ daySample: [HKQuantitySample]) -> Double? {
        
        guard let unit = getQueryUnit() else {
            return nil
        }
        
        var sum: Double = 0.0
        daySample.forEach { (sample) in
            sum += sample.quantity.doubleValue(for: unit)
        }
        
        return sum
        
    }
    
    // The greatest number of steps walked withouth stopping
    // Stopping: when the user stops walking for more than one minute
    func stepsSum(_ daySample: [HKQuantitySample]) -> [HealthKitDataModel:Double] {
        
        var result = [HealthKitDataModel:Double]()
        guard let metric = getQueryUnit() else {
            return result
        }
        
        var countSamples = [Double]()
        var samplesSum: Double = 0
        var i = 0
        var startIndex = 0
        while i < daySample.count {
            
            startIndex = i
            samplesSum = daySample[startIndex].quantity.doubleValue(for: metric)
            
            // check if next sample start date is less than one minute than the currentEnd date
            while i + 1 < daySample.count && (daySample[i].endDate).isLessThanOneMinute(daySample[i + 1].startDate) {
                i += 1
                samplesSum += daySample[i].quantity.doubleValue(for: metric)
            }
            
            countSamples.append(samplesSum)
            i += 1
        }
        
        if let max = countSamples.max() {
            result[.maxNonStopSteps] = max
        }
        
        let total = countSamples.reduce(0) {$0 + $1}
        result[.totalSteps] = total
        
        return result
    }
    
}

//Interpretation Methods
extension CumulativeCollector {
    
    fileprivate func getQueryMetric() -> HKQuantityType? {
        guard let metric = collectionMetric else {
            return nil
        }
        
        switch metric {
        case .maxNonStopSteps:
            fallthrough
        case .totalSteps:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        case .totalFlights:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)
        case .distanceWalked:
            return HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
            
        }
    }
    
    fileprivate func getQueryUnit() -> HKUnit? {
        
        guard let metric = collectionMetric else {
            return nil
        }
        
        switch metric {
        case .maxNonStopSteps:
            fallthrough
        case .totalSteps:
        fallthrough //we want count
        case .totalFlights:
            return HKUnit.count()
        case .distanceWalked:
            return HKUnit.meter()
            
        }
        
    }
    
}
