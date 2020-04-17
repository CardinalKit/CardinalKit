//
//  DMAttitudePayload.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 12/5/17.
//  Copyright © 2017 VascTrac. All rights reserved.
//

import CoreMotion

class DMAttitudePayload : CSVExporting {
    
    var m_Attitude: CMAttitude?
    
    var m_WallTime: CFAbsoluteTime = 0
    var m_SensorTime: Double = 0
    var m_Timer: Double = 0
    
    //Quaternion representation of attitude
    fileprivate var x: Double {
        get {
            return m_Attitude?.quaternion.x ?? -1.0
        }
    }
    
    fileprivate var y: Double {
        get {
            return m_Attitude?.quaternion.y ?? -1.0
        }
    }
    
    fileprivate var z: Double {
        get {
            return m_Attitude?.quaternion.z ?? -1.0
        }
    }
    
    fileprivate var w: Double {
        get {
            return m_Attitude?.quaternion.w ?? -1.0
        }
    } //END Quaternion
    
    convenience init(fromData data: CMDeviceMotion) {
        self.init()
        
        m_Attitude = data.attitude
    }
    
    func setTimestamp(wallTime: Double?, timer: Double?, sensorTime: Double) {
        m_WallTime = wallTime ?? CFAbsoluteTimeGetCurrent()
        m_SensorTime = sensorTime
        m_Timer = timer ?? 0
    }
    
    static func templateString() -> String {
        return "WallTime,SensorTime,Timer,x,y,z,w\n"
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_WallTime),\(m_SensorTime),\(m_Timer),\(x),\(y),\(z),\(w)\n"
    }
    
}
