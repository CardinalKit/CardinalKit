//
//  PedometerPayload.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 9/13/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import CoreMotion

class PedometerPayload : CSVExporting {
    
    var m_WallTime: CFAbsoluteTime = 0
    var m_Timer: Double = 0
    var m_StartDate: String = ""
    var m_EndDate: String = ""
    
    var m_Steps: Int = -1
    var m_Distance: Float = -1.0
    var m_Cadence: Float = -1.0
    var m_Pace: Float = -1.0
    var m_FloorsAscended: Float = -1.0
    var m_FloorsDescended: Float = -1.0
    
    convenience init(fromData data: CMPedometerData) {
        self.init()
        
        m_Steps = data.numberOfSteps.intValue
        m_Distance = data.distance?.floatValue ?? -1.0
        m_Cadence = data.currentCadence?.floatValue ?? -1.0
        m_Pace = data.currentPace?.floatValue ?? -1.0
        m_FloorsAscended = data.floorsAscended?.floatValue ?? -1.0
        m_FloorsDescended = data.floorsDescended?.floatValue ?? -1.0
    }
    
    func setTimestamp(wallTime: Double?, timer: Double?, startDate: String, endDate: String) {
        m_WallTime = wallTime ?? CFAbsoluteTimeGetCurrent()
        m_Timer = timer ?? 0
        m_StartDate = startDate
        m_EndDate = endDate
    }
    
    func toDictionary() -> [String:Any] {
        
        var iterationData = [String:Any]()
        iterationData["wall_time"] = m_WallTime
        iterationData["startDate"] = m_StartDate
        iterationData["endDate"] = m_EndDate
        iterationData["seconds"] = m_Timer
        iterationData["steps_without_stopping"] = m_Steps
        iterationData["distance"] = m_Distance
        iterationData["pace"] = m_Pace
        iterationData["cadence"] = m_Cadence
        iterationData["floors_ascended"] = m_FloorsAscended
        iterationData["floors_descended"] = m_FloorsDescended
        
        return iterationData
    }
    
    static func templateString() -> String {
        return "WallTime,Timer,StartDate,EndDate,Steps,Distance,Cadence,Pace,FloorsAscended,FloorsDescended\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_WallTime),\(m_Timer),\(m_StartDate),\(m_EndDate),\(m_Steps),\(m_Distance),\(m_Cadence),\(m_Pace),\(m_FloorsAscended),\(m_FloorsDescended)\n"
    }
    
}
