//
//  CKActivityManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/23/20.
//

import Foundation
import HealthKit

public class CKActivityManager : NSObject {
    
    public static let shared = CKActivityManager()
    
    public override init() {
        super.init()
        
        _ = HealthKitManager.shared
    }
    
    public func load() {
        guard hasGrantedAuth && !typesToCollect.isEmpty else {
            return
        }
        
        getHealthAuthorizaton(forTypes: self.typesToCollect) { [weak self] (success, error) in
            if (success) {
                self?.startHealthKitCollectionInBackground(withFrequency: .hourly) // TODO: get last freq
            }
        }
    }
    
    public func fetchData(route: String, onCompletion: @escaping (Any) -> Void){
        DownloadManager.shared.fetchData(route: route, onCompletion: onCompletion)
    }
    
    public func getHealthAuthorizaton(forTypes typesToCollect:Set<HKSampleType>, _ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if (typesToCollect.isEmpty){
           self.typesToCollect = initWithAllTypes()
       }
       else{
           
           self.typesToCollect = typesToCollect
       }
        HealthKitManager.shared.getHealthKitAuth(forTypes: self.typesToCollect) { [weak self] (success, error) in
            self?.hasGrantedAuth = success
            completion(success, error)
        }
    }
    
    func initWithAllTypes() -> Set<HKSampleType>{
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
    
    public func startHealthKitCollectionInBackground(fromStartDate startDate: Date? = nil, withFrequency frequency: HKUpdateFrequency, _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil) {
        
        //check for auth
        guard hasGrantedAuth else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot startHealthKitCollection without getting auth permissions first."])
            completion?(false, error)
            return
        }
        
        //record beginning of data collection
        if let startDate = startDate {
            UserDefaults.standard.set(startDate, forKey: Constants.UserDefaults.HKStartDate)
        }
        
        //and get health authorization
        HealthKitManager.shared.startBackgroundDelivery(forTypes: typesToCollect, withFrequency: frequency) { [weak self] (success, error) in
            self?.hasStartedCollection = success
            completion?(success, error)
        }
        
    }
    
    public func collectAllDataBetweenSpecificDates(fromDate startDate: Date? = nil,_ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil){
        
        guard hasGrantedAuth else {
            let error = NSError(domain: Constants.app, code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot startHealthKitCollection without getting auth permissions first."])
            completion?(false, error)
            return
        }
        
        HealthKitManager.shared.startCollectAllData(forTypes: typesToCollect, fromDate: startDate) { (success, error) in
            self.hasStartedCollection = success
            completion?(success, error)
        }
        
    }
    
    public func stopHealthKitCollection() {
        HealthKitManager.shared.disableHealthKit() { [weak self] (success, error) in
            if (success) { //disable successfully
                self?.hasStartedCollection = false //we have disabled
            }
        }
    }
    
     fileprivate let keyHasStartedCollection = "hasStartedCollection"
     fileprivate let keyHasGrantedAuth = "hasGrantedAuth"
     fileprivate let keyTypesToCollect = "typesToCollect"
     
     fileprivate var hasStartedCollection : Bool {
         get {
             return UserDefaults.standard.bool(forKey: keyHasStartedCollection)
         }
         set {
             UserDefaults.standard.set(newValue, forKey: keyHasStartedCollection)
         }
     }
     
     fileprivate var hasGrantedAuth : Bool {
         get {
             return UserDefaults.standard.bool(forKey: keyHasGrantedAuth)
         }
         set {
             UserDefaults.standard.set(newValue, forKey: keyHasGrantedAuth)
         }
     }
     
     fileprivate var _typesToCollect = Set<HKSampleType>()
     fileprivate var typesToCollect: Set<HKSampleType> {
         get {
             if (!_typesToCollect.isEmpty) {
                 return _typesToCollect
             }
             
             guard let typeIds = UserDefaults.standard.array(forKey: keyTypesToCollect) as? [String] else {
                 return Set<HKSampleType>() // no types to process
             }
             
             var types = Set<HKSampleType>()
             for type in typeIds {
                 let type = HKQuantityTypeIdentifier(rawValue: type)
                 if let parsedType = HKQuantityType.quantityType(forIdentifier: type) {
                     types.insert(parsedType)
                 }
             }
             
             if (!types.isEmpty) {
                 _typesToCollect = types
             }
             return types
         }
         set {
             var typeIds = [String]()
             for type in newValue {
                 typeIds.append(type.identifier)
             }
             UserDefaults.standard.set(typeIds, forKey: keyTypesToCollect)
             _typesToCollect = newValue
         }
     }
    
}
