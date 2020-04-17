//
//  ChestStrapHRPayload.swift
//  VascTrac
//
//  Created by Jeong Woo Ha on 4/23/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation


class ChestStrapHRPayload: CSVExporting {
    
    var m_WallTime: CFAbsoluteTime = 0
    var m_Timer: Double = 0
    var m_HeartRate: Double = 0
    
    convenience init(with heartRate: Double) {
        self.init()
        
        m_HeartRate = heartRate
    }
    
    func setTimestamp(wallTime: Double?, timer: Double?) {
        m_WallTime = wallTime ?? CFAbsoluteTimeGetCurrent()
        m_Timer = timer ?? 0
    }
    
    func toDictionary() -> [String: Any] {
        var iterationData = [String: Any]()
        iterationData["WallTime"] = m_WallTime
        iterationData["Timer"] = m_Timer
        iterationData["HeartRate"] = m_HeartRate
        
        return iterationData
    }
    
    static func templateString() -> String {
        return "WallTime,Timer,HeartRate\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_WallTime),\(m_Timer),\(m_HeartRate)\n"
    }

}
