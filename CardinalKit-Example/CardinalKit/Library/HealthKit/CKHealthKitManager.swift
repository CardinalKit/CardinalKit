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
    
    /* **************************************************************
     * Customize HealthKit data that will be collected
     * in the background. Choose from any HKCategoryType:
     * https://developer.apple.com/documentation/healthkit/hkcategorytypeidentifier
     **************************************************************/
    
    private let categoryTypesToRead: [HKCategoryTypeIdentifier] = [
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
        CKApp.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) { [weak self] (success, error) in
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
        CKApp.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) {(success, error) in
            DispatchQueue.main.async {
                if (success) {
                    CKActivityManager.shared.collectAllDataBetweenSpecificDates(fromDate: Date().dayByAdding(-10), completion)
                }
                completion(success, error)
            }
        }
    }
    
}
