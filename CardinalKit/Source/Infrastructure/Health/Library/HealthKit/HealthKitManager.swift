//
//  HealthKit.swift
//  abseil
//
//  Created by Esteban Ramos on 4/04/22.
//

import Foundation

import HealthKit

public class HealthKitManager{
    public let defaultTypes:[HKSampleType] = []
    lazy var healthStore: HKHealthStore = HKHealthStore()
    fileprivate let queryLogMutex = NSLock()
    fileprivate var queryLog = [String:Date]()
    fileprivate let timeBetweenQueries: TimeInterval = 60
    
    func startHealthKitCollectionInBackground(withFrequency frequency:String, forTypes types:Set<HKSampleType>){
        var _frequency:HKUpdateFrequency = .immediate
        if frequency == "daily" {
            _frequency = .daily
        } else if frequency == "weekly" {
           _frequency = .weekly
        } else if frequency == "hourly" {
           _frequency = .hourly
        }
        self.setUpBackgroundCollection(withFrequency: _frequency, forTypes: types)
    }
    
    func startCollectionByDayBetweenDate(fromDate startDate:Date, toDate endDate:Date?, forTypes types:Set<HKSampleType>){
        self.setUpCollectionByDayBetweenDates(fromDate: startDate, toDate: endDate, forTypes: types)
    }
}

extension HealthKitManager{
    
    private func setUpBackgroundCollection(withFrequency frequency:HKUpdateFrequency, forTypes types:Set<HKSampleType>, onCompletion:((_ success: Bool, _ error: Error?) -> Void)? = nil){
        var copyTypes = types
        let element = copyTypes.removeFirst()
        let query = HKObserverQuery(sampleType: element, predicate: nil, updateHandler: {
            (query, completionHandler, error) in
            
            //TODO: review if only first time all types are configured
            
            if(copyTypes.count>0){
                self.setUpBackgroundCollection(withFrequency: frequency, forTypes: copyTypes)
                copyTypes.removeAll()
            }
            
            //Update new data to send
            
            completionHandler()
        })
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: element, frequency: frequency, withCompletion: { (success, error) in
            if let error = error {
                VError("%@", error.localizedDescription)
            }
            onCompletion?(success,error)
        })
    }
    
    private func collectData(forType type:HKSampleType, fromDate startDate: Date? = nil, toDate endDate:Date?=nil, onCompletion:(()->Void?)){
        getSources(forType: type){ [weak self] (sources) in
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            defer {
                dispatchGroup.leave()
            }
            for source in sources {
                dispatchGroup.enter()
            }
        }
    }
    
    fileprivate func getSources(forType type: HKSampleType, onCompletion: @escaping ((Set<HKSource>)->Void)) {
        let datePredicate = HKQuery.predicateForSamples(withStart: Date().dayByAdding(-10)! , end: Date(), options: .strictStartDate)
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
        healthStore.execute(query)
    }
    
    private func setUpCollectionByDayBetweenDates(fromDate startDate:Date, toDate endDate:Date?, forTypes types:Set<HKSampleType>){
        
        
    }
}
