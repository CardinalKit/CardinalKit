//
//  HealthKit.swift
//  abseil
//
//  Created by Esteban Ramos on 4/04/22.
//

import Foundation

import HealthKit

public class HealthKitManager{
    
    lazy var healthStore: HKHealthStore = HKHealthStore()
    var types:Set<HKSampleType> = Set([])
    
    init(){
        types = defaultTypes()
    }
    
    public func configure(types: Set<HKSampleType>){
        self.types = types
    }
    
    func startHealthKitCollectionInBackground(withFrequency frequency:String){
        var _frequency:HKUpdateFrequency = .immediate
        if frequency == "daily" {
            _frequency = .daily
        } else if frequency == "weekly" {
           _frequency = .weekly
        } else if frequency == "hourly" {
           _frequency = .hourly
        }
        self.setUpBackgroundCollection(withFrequency: _frequency, forTypes: types.isEmpty ? defaultTypes() : types)
    }
    
    func startCollectionByDayBetweenDate(fromDate startDate:Date, toDate endDate:Date?){
        self.setUpCollectionByDayBetweenDates(fromDate: startDate, toDate: endDate, forTypes: types)
    }
}



extension HealthKitManager{
    
    private func setUpCollectionByDayBetweenDates(fromDate startDate:Date, toDate endDate:Date?, forTypes types:Set<HKSampleType>){
        var copyTypes = types
        let element = copyTypes.removeFirst()
        
        collectDataDayByDay(forType: element, fromDate: startDate, toDate: endDate ?? Date()){ samples in
            if(copyTypes.count>0){
                self.setUpCollectionByDayBetweenDates(fromDate: startDate, toDate: endDate, forTypes: types)
                copyTypes.removeAll()
            }
        }
        
    }
    
    private func setUpBackgroundCollection(withFrequency frequency:HKUpdateFrequency, forTypes types:Set<HKSampleType>, onCompletion:((_ success: Bool, _ error: Error?) -> Void)? = nil){
        var copyTypes = types
        let element = copyTypes.removeFirst()
        let query = HKObserverQuery(sampleType: element, predicate: nil, updateHandler: {
            (query, completionHandler, error) in
            if(copyTypes.count>0){
                self.setUpBackgroundCollection(withFrequency: frequency, forTypes: copyTypes, onCompletion: onCompletion)
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
                    _startDate = (self?.getLastSyncDate(forType: type,forSource: sourceRevision))!
                }
                
                self?.queryHealthStore(forType: type, forSource: sourceRevision, fromDate: _startDate, toDate: endDate) { (query: HKSampleQuery, results: [HKSample]?, error: Error?) in
                    
                    if let error = error {
                        VError("%@", error.localizedDescription)
                    }
                    guard let results = results, !results.isEmpty else {
                        onCompletion([HKSample]())
                        
                        return
                    }
                    
                    self?.saveLastSyncDate(forType: type, forSource: sourceRevision, date: Date())
                    CKApp.instance.infrastructure.onHealthDataColected(data: results)
                    onCompletion(results)
                }
            }
        }
    }
    
    private func collectDataDayByDay(forType type:HKSampleType, fromDate startDate: Date, toDate endDate:Date, onCompletion:@escaping (([HKSample])->Void)){
        collectData(forType: type, fromDate: startDate, toDate: startDate.dayByAdding(1)!, onCompletion: onCompletion)
        let newStartDate = startDate.dayByAdding(1)!
        if newStartDate < endDate{
            collectDataDayByDay(forType: type, fromDate: newStartDate, toDate: endDate, onCompletion: onCompletion)
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
    
    func saveLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision, date:Date){
        let lastSyncObject =
            DateLastSyncObject(
                dataType: "\(type.identifier)",
                lastSyncDate: date,
                device: "\(getSourceRevisionKey(source: sourceRevision))"
            )
        CKApp.instance.options.localDBDelegate?.saveLastSyncItem(item: lastSyncObject)
    }
    
    func getLastSyncDate(forType type: HKSampleType, forSource sourceRevision: HKSourceRevision) -> Date
    {
        let queryParams:[String:AnyObject] = [
            "dataType":"\(type.identifier)" as AnyObject,
            "device":"\(getSourceRevisionKey(source: sourceRevision))" as AnyObject
        ]
        if let result = CKApp.instance.options.localDBDelegate?.getLastSyncItem(params:queryParams){
            return result.lastSyncDate
        }
        return Date().dayByAdding(-1)!
    }
    
    fileprivate func getSourceRevisionKey(source: HKSourceRevision) -> String {
        return "\(source.productType ?? "UnknownDevice") \(source.source.key)"
    }
}


extension HealthKitManager{
    
    func defaultTypes() -> Set<HKSampleType>{
        var hkTypesToReadInBackground: Set<HKSampleType> = []
        
        /* **************************************************************
         * Customize HealthKit data that will be collected
         * in the background. Choose from any HKQuantityType:
         * https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
         **************************************************************/
        
        let quantityTypesToRead: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned,
            .appleExerciseTime,
            .appleStandTime,
            .basalBodyTemperature,
            .basalEnergyBurned,
            .bloodAlcoholContent,
            .bloodGlucose,
            .bloodPressureDiastolic,
            .bloodPressureSystolic,
            .bodyFatPercentage,
            .bodyMass,
            .bodyMassIndex,
            .bodyTemperature,
            .dietaryBiotin,
            .dietaryCaffeine,
            .dietaryCalcium,
            .dietaryCarbohydrates,
            .dietaryChloride,
            .dietaryCholesterol,
            .dietaryChromium,
            .dietaryCopper,
            .dietaryEnergyConsumed,
            .dietaryFatMonounsaturated,
            .dietaryFatPolyunsaturated,
            .dietaryFatSaturated,
            .dietaryFatTotal,
            .dietaryFiber,
            .dietaryFolate,
            .dietaryIodine,
            .dietaryIron,
            .dietaryMagnesium,
            .dietaryManganese,
            .dietaryMolybdenum,
            .dietaryNiacin,
            .dietaryPantothenicAcid,
            .dietaryPhosphorus,
            .dietaryPotassium,
            .dietaryProtein,
            .dietaryRiboflavin,
            .dietarySelenium,
            .dietarySodium,
            .dietarySugar,
            .dietaryThiamin,
            .dietaryVitaminA,
            .dietaryVitaminB12,
            .dietaryVitaminB6,
            .dietaryVitaminC,
            .dietaryVitaminD,
            .dietaryVitaminE,
            .dietaryVitaminK,
            .dietaryWater,
            .dietaryZinc,
            .distanceCycling,
            .distanceDownhillSnowSports,
            .distanceSwimming,
            .distanceWalkingRunning,
            .distanceWheelchair,
            .electrodermalActivity,
            .environmentalAudioExposure,
            .flightsClimbed,
            .forcedExpiratoryVolume1,
            .forcedVitalCapacity,
            .headphoneAudioExposure,
            .heartRate,
            .heartRateVariabilitySDNN,
            .height,
            .inhalerUsage,
            .insulinDelivery,
            .leanBodyMass,
            .nikeFuel,
            .numberOfTimesFallen,
            .oxygenSaturation,
            .peakExpiratoryFlowRate,
            .peripheralPerfusionIndex,
            .pushCount,
            .respiratoryRate,
            .restingHeartRate,
            .sixMinuteWalkTestDistance,
            .stairAscentSpeed,
            .stairDescentSpeed,
            .stepCount,
            .swimmingStrokeCount,
            .uvExposure,
            .vo2Max,
            .waistCircumference,
            .walkingAsymmetryPercentage,
            .walkingDoubleSupportPercentage,
            .walkingHeartRateAverage,
            .walkingSpeed,
            .walkingStepLength
        ]
        
        let categoryTypesToRead: [HKCategoryTypeIdentifier] = [
            .abdominalCramps,
            .acne,
            .appetiteChanges,
            .appleStandHour,
            .bladderIncontinence,
            .bloating,
            .breastPain,
            .cervicalMucusQuality,
            .chestTightnessOrPain,
            .chills,
            .constipation,
            .contraceptive,
            .coughing,
            .diarrhea,
            .dizziness,
            .drySkin,
            .environmentalAudioExposureEvent,
            .environmentalAudioExposureEvent,
            .fainting,
            .fatigue,
            .fever,
            .generalizedBodyAche,
            .hairLoss,
            .handwashingEvent,
            .headache,
            .headphoneAudioExposureEvent,
            .heartburn,
            .highHeartRateEvent,
            .hotFlashes,
            .intermenstrualBleeding,
            .irregularHeartRhythmEvent,
            .lactation,
            .lossOfSmell,
            .lossOfTaste,
            .lowCardioFitnessEvent,
            .lowCardioFitnessEvent,
            .lowHeartRateEvent,
            .lowerBackPain,
            .memoryLapse,
            .menstrualFlow,
            .mindfulSession,
            .moodChanges,
            .nausea,
            .nightSweats,
            .ovulationTestResult,
            .pelvicPain,
            .pregnancy,
            .rapidPoundingOrFlutteringHeartbeat,
            .runnyNose,
            .sexualActivity,
            .shortnessOfBreath,
            .sinusCongestion,
            .skippedHeartbeat,
            .sleepAnalysis,
            .sleepChanges,
            .soreThroat,
            .toothbrushingEvent,
            .vaginalDryness,
            .vomiting,
            .wheezing
        ]
        
        for quantityType in quantityTypesToRead {
           hkTypesToReadInBackground.insert(HKObjectType.quantityType(forIdentifier: quantityType)!)
       }

       for categoryType in categoryTypesToRead {
           hkTypesToReadInBackground.insert(HKObjectType.categoryType(forIdentifier: categoryType)!)
       }
        
        hkTypesToReadInBackground.insert(HKObjectType.documentType(forIdentifier: .CDA)!)
        hkTypesToReadInBackground.insert(HKElectrocardiogramType.electrocardiogramType())
        hkTypesToReadInBackground.insert(HKAudiogramSampleType.audiogramSampleType())
        hkTypesToReadInBackground.insert(HKWorkoutType.workoutType())
        hkTypesToReadInBackground.insert(HKAudiogramSampleType.audiogramSampleType())
        hkTypesToReadInBackground.insert(HKSeriesType.workoutRoute())
        hkTypesToReadInBackground.insert(HKSeriesType.heartbeat())
        
        return hkTypesToReadInBackground
    }
    
}

