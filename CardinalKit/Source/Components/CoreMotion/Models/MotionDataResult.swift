//
//  MotionDataResult.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 3/22/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

class MotionDataResult: NSObject {
    
    var device: DataProcessor.Device?
    var syncId: String = ""
    var motionStartDate = Date()
    
    var pedometerItems = [PedometerPayload]()
    var rawAccelerationItems = [AccelerationPayload]()
    var rawGyroItems = [GyroPayload]()
    var deviceMotionAttitude = [DMAttitudePayload]()
    var deviceMotionRotation = [DMRotationRatePayload]()
    var deviceMotionGravity = [DMGravityPayload]()
    var deviceMotionUserAcceleration = [DMUserAccelerationPayload]()
    var heartRateItems = [[HeartRatePayload]]()
    var chestStrapItems = [ChestStrapHRPayload]()
    var locationItems = [LocationPayload]()
    
    func isEmpty() -> Bool {
        return pedometerItems.isEmpty && rawAccelerationItems.isEmpty && rawGyroItems.isEmpty && deviceMotionAttitude.isEmpty && deviceMotionRotation.isEmpty && deviceMotionGravity.isEmpty && deviceMotionUserAcceleration.isEmpty && heartRateItems.isEmpty && chestStrapItems.isEmpty && locationItems.isEmpty
    }
    
    override var hash: Int {
        get {
            return syncId.hash
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? MotionDataResult else {
            return false
        }
        
        return self.syncId == object.syncId
    }
    
}
