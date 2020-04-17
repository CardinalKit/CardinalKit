//
//  HeartRatePayload.swift
//  WatchTrac Extension
//
//  Created by Santiago Gutierrez on 4/18/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import HealthKit

class HeartRatePayload : CSVExporting {
    
    var m_StartDate: String = ""
    var m_EndDate: String = ""
    
    var m_HeartRate: Double = 0
    var m_UnitString: String = ""
    
    var m_MotionContext: String = ""
    
    convenience init(fromData data: HKQuantitySample) {
        self.init()
        
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        m_HeartRate = data.quantity.doubleValue(for: unit)
        m_UnitString = unit.unitString
        
        m_StartDate = data.startDate.ISOStringFromDate()
        m_EndDate = data.endDate.ISOStringFromDate()
        
        if let motionContextRaw = data.metadata?[HKMetadataKeyHeartRateMotionContext] as? NSNumber,
            let motionContext = HKHeartRateMotionContext(rawValue: motionContextRaw.intValue){
            
            switch motionContext{
            case .notSet:
                m_MotionContext = "notSet"
            case .sedentary:
                m_MotionContext = "sedentary"
            case .active:
                m_MotionContext = "active"
            }
        }
    }
    
    func toDictionary() -> [String:Any] {
        var iterationData = [String:Any]()
        iterationData["start_date"] = m_StartDate
        iterationData["end_date"] = m_EndDate
        
        iterationData["heart_rate"] = m_HeartRate
        iterationData["unit"] = m_UnitString
        
        iterationData["motion_context"] = m_MotionContext
        
        return iterationData
    }
    
    static func templateString() -> String {
        return "StartDate,EndDate,HeartRate,Unit,Context\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_StartDate),\(m_EndDate),\(m_HeartRate),\(m_UnitString),\(m_MotionContext)\n"
    }
    
}
