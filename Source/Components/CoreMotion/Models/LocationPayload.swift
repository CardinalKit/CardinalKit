//
//  LocationPayload.swift
//  VascTrac
//
//  Created by JeongWoo Ha on 7/6/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

class LocationPayload: CSVExporting {
    
    var m_WallTime: CFAbsoluteTime = 0
    var m_Timer: Double = 0
    
    var deltaLat: Double = 0
    var deltaLon: Double = 0
    var distance: Double = 0
    var angle: Double = 0
    var altitude: Double = 0
    var timestamp: String = ""
    var horAcc: Double = -1
    var verAcc: Double = -1
    var course: Double = 0
    var speed: Double = 0
    var floor: String = "NULL"
    
    convenience init(with locationData: LocationData) {
        self.init()
        
        deltaLat = locationData.deltaLatitude
        deltaLon = locationData.deltaLongitude
        distance = locationData.distance
        angle = locationData.angle
        altitude = locationData.altitude
        timestamp = locationData.timestamp.ISOStringFromDate()
        horAcc = locationData.horizontalAccuracy
        verAcc = locationData.vertialAccuracy
        course = locationData.course
        speed = locationData.speed
        floor = locationData.floor != nil ? String(locationData.floor!) : "NULL"
    }
    
    func setTimestamp(wallTime: Double?, timer: Double?) {
        m_WallTime = wallTime ?? CFAbsoluteTimeGetCurrent()
        m_Timer = timer ?? 0
    }
    
    func toDictionary() -> [String: Any] {
        var iterationData = [String: Any]()
        iterationData["WallTime"] = m_WallTime
        iterationData["Timer"] = m_Timer
        iterationData["Timestamp"] = timestamp
        iterationData["DeltaLat"] = deltaLat
        iterationData["DeltaLon"] = deltaLon
        iterationData["Distance"] = distance
        iterationData["Angle"] = angle
        iterationData["Altitude"] = altitude
        iterationData["HorAcc"] = horAcc
        iterationData["VerAcc"] = verAcc
        iterationData["Course"] = course
        iterationData["Speed"] = speed
        iterationData["Floor"] = floor
        
        return iterationData
    }
    
    func exportAsCommaSeparatedString() -> String {
        return "\(m_WallTime),\(m_Timer),\(timestamp),\(deltaLat),\(deltaLon),\(distance),\(angle),\(altitude),\(horAcc),\(verAcc),\(course),\(speed),\(floor)\n"
    }
    
    static func templateString() -> String {
        return "WallTime,Timer,Timestamp,DeltaLat,DeltaLon,Distance,Angle,Altitude,HorAcc,VerAcc,Course,Speed,Floor\n"
    }
}
