//
//  HealthkitManager+HKTypes.swift
//  CardinalKit
//
//  Created by Esteban Ramos on 6/05/22.
//

import Foundation

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
