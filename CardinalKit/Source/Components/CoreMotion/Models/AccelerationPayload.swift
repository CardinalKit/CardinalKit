//
//  AccelerationPayload.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 9/13/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import CoreMotion

class AccelerationPayload : CSVExporting {
    
    var m_Acceleration: CMAcceleration?
    
    var m_WallTime: CFAbsoluteTime = 0
    var m_SensorTime: Double = 0
    var m_Timer: Double = 0
    
    fileprivate var x: Double {
        get {
            return m_Acceleration?.x ?? -1.0
        }
    }
    
    fileprivate var y: Double {
        get {
            return m_Acceleration?.y ?? -1.0
        }
    }
    
    fileprivate var z: Double {
        get {
            return m_Acceleration?.z ?? -1.0
        }
    }
    
    convenience init(fromData data: CMAccelerometerData) {
        self.init()
        
        m_Acceleration = data.acceleration
    }
    
    func setTimestamp(wallTime: Double?, timer: Double?, sensorTime: Double) {
        m_WallTime = wallTime ?? CFAbsoluteTimeGetCurrent()
        m_SensorTime = sensorTime
        m_Timer = timer ?? 0
    }
    
    func toDictionary() -> [String:Any] {
        
        var iterationData = [String:Any]()
        iterationData["WallTime"] = m_WallTime
        iterationData["SensorTime"] = m_SensorTime
        iterationData["Timer"] = m_Timer
        iterationData["x"] = m_Acceleration?.x ?? -1.0
        iterationData["y"] = m_Acceleration?.y ?? -1.0
        iterationData["z"] = m_Acceleration?.z ?? -1.0
        
        return iterationData
    }

    static func templateString() -> String {
        return "WallTime,SensorTime,Timer,x,y,z\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_WallTime),\(m_SensorTime),\(m_Timer),\(x),\(y),\(z)\n"
    }
    
}
