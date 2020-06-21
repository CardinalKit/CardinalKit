//
//  MotionAnalyzer.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 6/9/19.
//  Copyright © 2019 VascTrac. All rights reserved.
//

import Foundation

protocol MotionAnalyzerDelegate {
    func didUpdate(_ power: Float)
}

class MotionAnalyzer {
    
    var delegate: MotionAnalyzerDelegate?
    
    fileprivate let maxEntriesAtATime = 3
    
    var runningCadenceValues = [Float]()
    let runningCadenceMutex = NSLock()
    var averageCadence: Float {
        guard let average = runningCadenceValues.average else { return 0 }
        return average / Float(runningCadenceValues.count)
    }
    
    var runningXAccelValues = [Float]()
    var runningZAccelValues = [Float]()
    let runningAccelMutex = NSLock()
    var averageAccel: Float {
        guard let averageX = runningXAccelValues.average, let averageZ = runningZAccelValues.average else { return 0 }
        return sqrt(pow(averageX,2) + pow(averageZ,2))
    }
    /*var averageAccel: Float {
        assert(runningXAccelValues.count == runningZAccelValues.count)
        return magnitudeAccel / Float(runningXAccelValues.count)
    }*/
    
    var runningPower = [Float]()
    var power: Float {
        if averageCadence <= 0.0 {
            return 0.1 * abs(averageAccel)
        }
        return averageCadence * abs(averageAccel)
    }
    
    func update(power: Float) {
        guard power != 0 else { return }
        runningPower.append(power)
        if let averagePower = runningPower.average {
            delegate?.didUpdate(averagePower)
        }
    }
    
    func report(cadence: Float) {
        runningCadenceMutex.lock()
        defer {
            runningCadenceMutex.unlock()
        }
        
        if runningCadenceValues.count >= maxEntriesAtATime {
            runningCadenceValues.removeFirst()
        }
        
        #if os(iOS)
        /*DispatchQueue.main.async {
            Alerts.showInfo(message: "Cadence reported: \(cadence)")
        }*/
        #endif
        
        runningCadenceValues.append(cadence)
        print("reporting cadence: \(cadence)")
        update(power: power)
    }
    
    func report(xAccel: Float, zAccel: Float) {
        runningAccelMutex.lock()
        defer {
            runningAccelMutex.unlock()
        }
        
        if runningXAccelValues.count >= maxEntriesAtATime {
            runningXAccelValues.removeFirst()
        }
        if runningZAccelValues.count >= maxEntriesAtATime {
            runningZAccelValues.removeFirst()
        }
        
        runningXAccelValues.append(xAccel)
        runningZAccelValues.append(zAccel)
        update(power: power)
    }
    
    
}
