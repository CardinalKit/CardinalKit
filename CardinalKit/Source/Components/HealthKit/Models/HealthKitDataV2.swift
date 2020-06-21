//
//  HealthKitDataV2.swift
//  VascTrac
//
//  Created by Vineeth Gangaram on 9/17/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation
import HealthKit
import UIKit
import RealmSwift
import ObjectMapper

class HKSampleData: Object, Codable {
    var quantitySample: QuantitySampleData?
    //var categorySample: CategorySampleData?
    //var cdaSample: CDADocumentSampleData?
    //var correlationSample: CorrelationSampleData? //not sure about this one
    //var workoutSample: WorkoutSampleData?
    
    convenience init(sample: HKSample) {
        self.init()
        if let qs = sample as? HKQuantitySample {
            quantitySample = QuantitySampleData(sample: qs)
        }
    }
}

class QuantitySampleData: Object, Codable {
    
    var value: Double = 0
    var unit: String = ""
    var source: String = ""
    var type: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    
    convenience init?(sample: HKQuantitySample) {
        self.init()
        if let sampleUnit = QuantitySampleData.unitForQuantityType(type: sample.quantityType) {
            unit = sampleUnit.unitString
            value = sample.quantity.doubleValue(for: sampleUnit)
            source = sample.deviceKey
            type = sample.quantityType.identifier
            startDate = sample.startDate
            endDate = sample.endDate
        } else {
            return nil
        }
    }
    
    static func unitForQuantityType(type: HKQuantityType) -> HKUnit? {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return HKUnit.count()
        case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
            return HKUnit.meter()
        case HKQuantityTypeIdentifier.flightsClimbed.rawValue:
            return HKUnit.count()
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return HKUnit.count().unitDivided(by: HKUnit.minute())
        case HKQuantityTypeIdentifier.restingHeartRate.rawValue:
            return HKUnit.count().unitDivided(by: HKUnit.minute())
        case HKQuantityTypeIdentifier.height.rawValue:
            return HKUnit.meter()
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return HKUnit.gram()
        default:
            return nil
        }
    }
}
