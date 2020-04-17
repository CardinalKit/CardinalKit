//
//  StepsCollector.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 1/20/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit

@available(*, deprecated) //use HealthKitCollector and CumulativeCollector instead
class StepsCollector {
    
    // The greatest number of steps walked withouth stopping
    // Stopping: when the user stops walking for more than one minute
    static func stepsData(_ daySample: [HKQuantitySample]) -> (max: Int?, total: Int?) {
        
        var countSamples = [Int]()
        var samplesSum = 0
        var i = 0
        var startIndex = 0
        while i < daySample.count {
            
            startIndex = i
            samplesSum = Int(daySample[startIndex].quantity.doubleValue(for: HKUnit.count()))
            
            // check if next sample start date is less than one minute than the currentEnd date
            while i + 1 < daySample.count && (daySample[i].endDate).isLessThanOneMinute(daySample[i + 1].startDate) {
                i += 1
                samplesSum += Int(daySample[i].quantity.doubleValue(for: HKUnit.count()))
            }
            
            countSamples.append(samplesSum)
            i += 1
        }
        
        let max = countSamples.max()
        let total = countSamples.reduce(0) {$0 + $1}
        
        return (max, total)
    }
    
}
