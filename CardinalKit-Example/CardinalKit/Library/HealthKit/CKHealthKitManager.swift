//
//  CKHealthKitManager.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HealthKit
import CardinalKit

class CKHealthKitManager : NSObject {
    
    static let shared = CKHealthKitManager()
    
    // TODO: save as configurable element
    fileprivate var hkTypesToReadInBackground: Set<HKSampleType> = []
    
    fileprivate let config = CKConfig.shared
    
    /* **************************************************************
     * Customize HealthKit data that will be collected
     * in the background. Choose from any HKQuantityType:
     * https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
     **************************************************************/
    
    private let quantityTypesToRead: [HKQuantityTypeIdentifier] = [
        .bodyMassIndex,
        .bodyFatPercentage,
        .height,
        .bodyMass,
        .leanBodyMass,
        .waistCircumference,
        .stepCount,
        .distanceWalkingRunning,
        .distanceCycling,
        .distanceWheelchair,
        .basalEnergyBurned,
        .activeEnergyBurned,
        .flightsClimbed,
        .nikeFuel,
        .appleExerciseTime,
        .pushCount,
        .distanceSwimming,
        .swimmingStrokeCount,
        .vo2Max,
        .distanceDownhillSnowSports,
        .appleStandTime,
        .heartRate,
        .bodyTemperature,
        .basalBodyTemperature,
        .bloodPressureSystolic,
        .bloodPressureDiastolic,
        .respiratoryRate,
        .restingHeartRate,
        .walkingHeartRateAverage,
        .heartRateVariabilitySDNN,
        .oxygenSaturation,
        .peripheralPerfusionIndex,
        .bloodGlucose,
        .numberOfTimesFallen,
        .electrodermalActivity,
        .inhalerUsage,
        .insulinDelivery,
        .bloodAlcoholContent,
        .forcedVitalCapacity,
        .forcedExpiratoryVolume1,
        .peakExpiratoryFlowRate,
        .environmentalAudioExposure,
        .headphoneAudioExposure,
        .dietaryFatTotal,
        .dietaryFatPolyunsaturated,
        .dietaryFatMonounsaturated,
        .dietaryFatSaturated,
        .dietaryCholesterol,
        .dietarySodium,
        .dietaryCarbohydrates,
        .dietaryFiber,
        .dietarySugar,
        .dietaryEnergyConsumed,
        .dietaryProtein,
        .dietaryVitaminA,
        .dietaryVitaminB6,
        .dietaryVitaminB12,
        .dietaryVitaminC,
        .dietaryVitaminD,
        .dietaryVitaminE,
        .dietaryVitaminK,
        .dietaryCalcium,
        .dietaryIron,
        .dietaryThiamin,
        .dietaryRiboflavin,
        .dietaryNiacin,
        .dietaryFolate,
        .dietaryBiotin,
        .dietaryPantothenicAcid,
        .dietaryPhosphorus,
        .dietaryIodine,
        .dietaryMagnesium,
        .dietaryZinc,
        .dietarySelenium,
        .dietaryCopper,
        .dietaryManganese,
        .dietaryChromium,
        .dietaryMolybdenum,
        .dietaryChloride,
        .dietaryPotassium,
        .dietaryCaffeine,
        .dietaryWater,
        .uvExposure,
        .walkingSpeed,
        .walkingDoubleSupportPercentage,
        .walkingAsymmetryPercentage,
        .walkingStepLength,
        .sixMinuteWalkTestDistance,
        .stairAscentSpeed,
        .stairDescentSpeed
    ]
    
    /* **************************************************************
     * Customize HealthKit data that will be collected
     * in the background. Choose from any HKCategoryType:
     * https://developer.apple.com/documentation/healthkit/hkcategorytypeidentifier
     **************************************************************/
    
    private let categoryTypesToRead: [HKCategoryTypeIdentifier] = [
        .sleepAnalysis,
        .appleStandHour,
        .cervicalMucusQuality,
        .ovulationTestResult,
        .menstrualFlow,
        .intermenstrualBleeding,
        .sexualActivity,
        .mindfulSession,
        .highHeartRateEvent,
        .lowHeartRateEvent,
        .irregularHeartRhythmEvent,
        .environmentalAudioExposureEvent,
        .toothbrushingEvent,
        .pregnancy,
        .lactation,
        .contraceptive,
        .environmentalAudioExposureEvent,
        .headphoneAudioExposureEvent,
        .handwashingEvent,
        .lowCardioFitnessEvent,
        .abdominalCramps,
        .acne,
        .appetiteChanges,
        .bladderIncontinence,
        .bloating,
        .breastPain,
        .chestTightnessOrPain,
        .chills,
        .constipation,
        .coughing,
        .diarrhea,
        .dizziness,
        .drySkin,
        .fainting,
        .fatigue,
        .fever,
        .generalizedBodyAche,
        .hairLoss,
        .headache,
        .heartburn,
        .hotFlashes,
        .lossOfSmell,
        .lossOfTaste,
        .lowerBackPain,
        .lowCardioFitnessEvent,
        .memoryLapse,
        .moodChanges,
        .nausea,
        .nightSweats,
        .pelvicPain,
        .rapidPoundingOrFlutteringHeartbeat,
        .runnyNose,
        .shortnessOfBreath,
        .sinusCongestion,
        .skippedHeartbeat,
        .sleepChanges,
        .soreThroat,
        .vaginalDryness,
        .vomiting,
        .wheezing
    ]
    
    func readOtherTypes() -> Void {
        hkTypesToReadInBackground.insert(HKObjectType.documentType(forIdentifier: .CDA)!)
        hkTypesToReadInBackground.insert(HKElectrocardiogramType.electrocardiogramType())
        hkTypesToReadInBackground.insert(HKAudiogramSampleType.audiogramSampleType())
        hkTypesToReadInBackground.insert(HKWorkoutType.workoutType())
        hkTypesToReadInBackground.insert(HKAudiogramSampleType.audiogramSampleType())
        hkTypesToReadInBackground.insert(HKSeriesType.workoutRoute())
        hkTypesToReadInBackground.insert(HKSeriesType.heartbeat())
    }
    
    override init() {
        super.init()
        
        for quantityType in quantityTypesToRead {
            hkTypesToReadInBackground.insert(HKObjectType.quantityType(forIdentifier: quantityType)!)
        }
        
        for categoryType in categoryTypesToRead {
            hkTypesToReadInBackground.insert(HKObjectType.categoryType(forIdentifier: categoryType)!)
        }
        
        self.readOtherTypes()
        
    }
    
    /// Query for HealthKit Authorization
    /// - Parameter completion: (success, error)
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        // handle authorization from the OS
        CKActivityManager.shared.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) { [weak self] (success, error) in
            if (success) {
                let frequency = self?.config.read(query: "Background Read Frequency")
                
                if frequency == "daily" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .daily)
                } else if frequency == "weekly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .weekly)
                } else if frequency == "hourly" {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .hourly)
                } else {
                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .immediate)
                }
            }
            completion(success, error)
        }
    }
    
    
    func collectAllTypes(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        // handle authorization from the OS
        CKActivityManager.shared.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) {(success, error) in
            DispatchQueue.main.async {
                if (success) {
                    CKActivityManager.shared.collectAllDataBetweenSpecificDates(fromDate: Date().dayByAdding(-10), completion)
                }
                completion(success, error)
            }
        }
    }
    
}
