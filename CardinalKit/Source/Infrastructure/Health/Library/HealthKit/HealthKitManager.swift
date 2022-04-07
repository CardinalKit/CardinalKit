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
            if(copyTypes.count>0){
                self.setUpBackgroundCollection(withFrequency: frequency, forTypes: copyTypes)
                copyTypes.removeAll()
            }
            self.collectData(forType: element, fromDate: nil, toDate: Date()){ samples in
                print("Samples \(samples)")
                // TODO: send Data
            }
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
    
    
    
    private func collectData(forType type:HKSampleType, fromDate startDate: Date? = nil, toDate endDate:Date, onCompletion:@escaping (([HKSample])->Void?)){
        getSources(forType: type){ [weak self] (sources) in
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            defer {
                dispatchGroup.leave()
            }
            VLog("Got sources for type %@", sources.count, type.identifier)
            for source in sources {
                dispatchGroup.enter()
                let sourceRevision = HKSourceRevision(source: source, version: HKSourceRevisionAnyVersion)
                var _startDate = Date().addingTimeInterval(-1)
                if let startDate = startDate {
                    _startDate = startDate
                }
                else{
                    _startDate = CKApp.instance.getLastSyncDate(forType: type,forSource: sourceRevision)
                }
                
                self?.queryHealthStore(forType: type, forSource: sourceRevision, fromDate: _startDate, toDate: endDate) { (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
                    
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
    
    fileprivate func queryHealthStore(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, fromDate startDate: Date, toDate endDate: Date, queryHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void) {
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sourcePredicate = HKQuery.predicateForObjects(from: [sourceRevision])
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [datePredicate, sourcePredicate])
        
        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 1000, sortDescriptors: [sortDescriptor]) {
            (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
            queryHandler(query, results, error)
        }
        
        healthStore.execute(query)
        
    }
    
    private func setUpCollectionByDayBetweenDates(fromDate startDate:Date, toDate endDate:Date?, forTypes types:Set<HKSampleType>){
        
        
    }
}
