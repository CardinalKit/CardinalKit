//
//  MotionController.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 12/5/17.
//  Copyright © 2017 VascTrac. All rights reserved.
//

import Foundation
import CoreMotion

#if os(watchOS)
import HealthKit
#endif

protocol MotionDelegate : class {
    func pedometer(_ result: PedometerPayload)
    func pedometer(didStallAfter timeout: Double)
}

class MotionController {
    
    static let maxStreamSize: Int = 10000
    
    var delegate : MotionDelegate?//s = [MotionDelegate]()
    
    /// parent for real-time data analysis
    var motionAnalyzer = MotionAnalyzer()
    
    fileprivate let pedometer = CMPedometer()
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate lazy var motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 9
        return queue
    }()
    
    /// walk inactivity timer
    fileprivate let inactivityTimeLimit: Double = 60.0
    fileprivate var inactivityDuration: Double = 0.0
    
    fileprivate var isRunning: Bool = false
    fileprivate var isStreaming: Bool = false
    fileprivate var streamTimer: Timer?
    
    var automaticStreaming: Bool = false
    
    var startDate = Date()
    var lastStreamDate = Date()
    var startTime = CFAbsoluteTimeGetCurrent()
    var streamSize = maxStreamSize
    
    var syncId: String = ""
    var device: DataProcessor.Device = .phone
    
    var pedometerItems = [PedometerPayload]()
    var rawAccelerationItems = [AccelerationPayload]()
    var rawGyroItems = [GyroPayload]()
    var deviceMotionAttitude = [DMAttitudePayload]()
    var deviceMotionRotation = [DMRotationRatePayload]()
    var deviceMotionGravity = [DMGravityPayload]()
    var deviceMotionUserAcceleration = [DMUserAccelerationPayload]()
    
    
    init() {
        semaphores = [pedometerSemaphore, rawAccelSemaphore, rawGyroSemaphore, dmAttitudeSemaphore, dmRotationSemaphore, dmGravitySemaphore, dmUserAccelSemaphore, chestStrapSemaphore, heartRateSemaphore, locationSemaphore]
    }
    
    var currentTime: Double {
        get {
            return CFAbsoluteTimeGetCurrent()
        }
    }
    
    var timer: Double {
        get {
            return CFAbsoluteTimeGetCurrent() - startTime
        }
    }
    
    var shouldStream: Bool {
        if isStreaming {
            return false
        }
        
        return rawAccelerationItems.count > self.streamSize ||
            rawGyroItems.count > self.streamSize ||
            deviceMotionAttitude.count > self.streamSize ||
            deviceMotionRotation.count > self.streamSize ||
            deviceMotionGravity.count > self.streamSize ||
            deviceMotionUserAcceleration.count > self.streamSize
    }
    
    func start() {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        
        if !rawAccelerationItems.isEmpty { //most other entries are based on accelerometer values
            pedometerItems = [PedometerPayload]()
            rawAccelerationItems = [AccelerationPayload]()
            rawGyroItems = [GyroPayload]()
            deviceMotionAttitude = [DMAttitudePayload]()
            deviceMotionRotation = [DMRotationRatePayload]()
            deviceMotionGravity = [DMGravityPayload]()
            deviceMotionUserAcceleration = [DMUserAccelerationPayload]()
            chestStrapHRItems = [ChestStrapHRPayload]()
            locationItems = [LocationPayload]()
        }
        
        startDate = Date()
        lastStreamDate = startDate
        startTime = CFAbsoluteTimeGetCurrent()
        
        startMotionUpdates()
        
        if automaticStreaming {
            streamTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(advanceStreamTimer(timer:)), userInfo: nil, repeats: true)
        }
        
        #if os(iOS)
        LocationManager.shared.start()
        // subscribe to LocationManager delegate here
        startLocationUpdates()
        #endif
    }
    
    func stop() {
        guard isRunning else {
            return
        }
        
        isRunning = false
        
        pedometer.stopUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        
        streamTimer?.invalidate()
        
        #if os(iOS)
        LocationManager.shared.stop()
        stopLocationUpdates()
        #endif
    }
    
    func getMotionData() -> MotionDataResult {
        let result = MotionDataResult()
        guard !self.syncId.isEmpty else {
            return result //empty result, don't collect anything...
        }
        
        result.motionStartDate = self.startDate
        result.syncId = self.syncId
        result.device = self.device
        
        result.pedometerItems = self.pedometerItems
        result.rawAccelerationItems = self.rawAccelerationItems
        result.rawGyroItems = self.rawGyroItems
        result.deviceMotionAttitude = self.deviceMotionAttitude
        result.deviceMotionRotation = self.deviceMotionRotation
        result.deviceMotionGravity = self.deviceMotionGravity
        result.deviceMotionUserAcceleration = self.deviceMotionUserAcceleration
        result.chestStrapItems = self.chestStrapHRItems
        result.heartRateItems = self.heartRateItems
        result.locationItems = self.locationItems
        
        return result
    }
    
    /*func add(delegate: MotionDelegate) {
        if let _ = delegates.index(where: { $0 === delegate }) {
            return
        }
        
        delegates.append(delegate)
    }
    
    func remove(delegate: MotionDelegate) {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
    }*/
    
    fileprivate func streamHelper(removeCurrentItems: Bool = true) {
        
        streamSemaphore.wait()
        isStreaming = true
        
        semaphores.forEach { (semaphore) in
            semaphore.wait() //stop streaming all data
        }
        
        let resultsCopy = getMotionData()
        if !resultsCopy.isEmpty() {
            lastStreamDate = Date()
            DataStreamer.shared.stream(resultsCopy)
            
            if removeCurrentItems {
                removeCache()
            }
        }
        
        semaphores.forEach { (semaphore) in
            semaphore.signal() //continue streaming all data
        }
        
        isStreaming = false
        streamSemaphore.signal()
    }
    
    fileprivate func removeCache() {
        pedometerItems.removeAll()
        rawAccelerationItems.removeAll()
        rawGyroItems.removeAll()
        deviceMotionAttitude.removeAll()
        deviceMotionRotation.removeAll()
        deviceMotionGravity.removeAll()
        deviceMotionUserAcceleration.removeAll()
        chestStrapHRItems.removeAll()
        heartRateItems.removeAll()
        locationItems.removeAll()
    }
    
    fileprivate func startMotionUpdates() {
        
        pedometer.startUpdates(from: Date()) { [weak self] (data: CMPedometerData?, error: Error?) in
            
            guard let strongSelf = self else {
                return
            }
            
            // update inactivity duration if new data comes in
            strongSelf.updateInactivityDuration()
            
            if let data = data {
                strongSelf.pedometerSemaphore.wait()
                
                let pedometer = PedometerPayload(fromData: data)
                
                let startDate = data.startDate.ISOStringFromDate()
                let endDate = data.endDate.ISOStringFromDate()
                pedometer.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, startDate: startDate, endDate: endDate)
                
                strongSelf.pedometerItems.append(pedometer)
                strongSelf.delegate?.pedometer(pedometer)
                
                if let cadence = data.currentCadence?.floatValue {
                    self?.motionAnalyzer.report(cadence: cadence)
                }
                strongSelf.pedometerSemaphore.signal()
            }
            
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdates(to: motionQueue) { [weak self] (data: CMAccelerometerData?, error: Error?) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if let data = data {
                    strongSelf.rawAccelSemaphore.wait()
                    
                    let accelerometer = AccelerationPayload(fromData: data)
                    accelerometer.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    
                    strongSelf.rawAccelerationItems.append(accelerometer)
                    
                    strongSelf.rawAccelSemaphore.signal()
                }
                
            }
        }
        
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.01
            motionManager.startGyroUpdates(to: motionQueue, withHandler: { [weak self] (data: CMGyroData?, error: Error?) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if let data = data {
                    strongSelf.rawGyroSemaphore.wait()
                    
                    let gyro = GyroPayload(fromData: data)
                    gyro.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    
                    strongSelf.rawGyroItems.append(gyro)
                    
                    strongSelf.rawGyroSemaphore.signal()
                }
                
            })
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: { [weak self] (data: CMDeviceMotion?, error: Error?) in
               
                guard let strongSelf = self else {
                    return
                }
                
                if let data = data  {
                    
                    strongSelf.dmAttitudeSemaphore.wait()
                    let attitude = DMAttitudePayload(fromData: data)
                    attitude.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    strongSelf.deviceMotionAttitude.append(attitude)
                    strongSelf.dmAttitudeSemaphore.signal()
                    
                    strongSelf.dmRotationSemaphore.wait()
                    let rotationRate = DMRotationRatePayload(fromData: data)
                    rotationRate.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    strongSelf.deviceMotionRotation.append(rotationRate)
                    strongSelf.dmRotationSemaphore.signal()
                    
                    strongSelf.dmGravitySemaphore.wait()
                    let gravity = DMGravityPayload(fromData: data)
                    gravity.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    strongSelf.deviceMotionGravity.append(gravity)
                    strongSelf.dmGravitySemaphore.signal()
                    
                    strongSelf.dmUserAccelSemaphore.wait()
                    let userAcceleration = DMUserAccelerationPayload(fromData: data)
                    userAcceleration.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer, sensorTime: data.timestamp)
                    strongSelf.deviceMotionUserAcceleration.append(userAcceleration)
                    if let validX = userAcceleration.m_UserAcceleration?.x, let validZ = userAcceleration.m_UserAcceleration?.z {
                        self?.motionAnalyzer.report(xAccel: Float(validX), zAccel: Float(validZ))
                    }
                    strongSelf.dmUserAccelSemaphore.signal()
                    
                }
                
            })
        }
        
    }
    
    @objc func advanceStreamTimer(timer: Timer) {
        if self.shouldStream {
            self.stream()
        } 
        
        checkWalkInactivity()
    }
    
    fileprivate func checkWalkInactivity() {
        if inactivityDuration >= inactivityTimeLimit {
            // end open walk test
            delegate?.pedometer(didStallAfter: inactivityDuration)
            return
        }
        
        inactivityDuration += 10
    }
    
    fileprivate func updateInactivityDuration() {
        inactivityDuration = 0.0 // reset inactivity status
    }
    
    //checks if motion permissions have been granted
    static func checkPermissions(_ onCompletion: @escaping (Bool) -> Void){
        
        let motionActivityManager = CMMotionActivityManager()
        let now = Date()
        motionActivityManager.queryActivityStarting(from: now, to: now, to: OperationQueue.main) { (motionActivities, error) in
            
            if let error = error, (error  as NSError).code == Int(CMErrorMotionActivityNotAuthorized.rawValue) {
                
                //UserDefaults.standard.set(false, forKey: "hasMotionActivityPermission")
                onCompletion(false) //not authorized to continue
                return
            }
            
            let result = motionActivities != nil ? true : false
            //UserDefaults.standard.set(result, forKey: "hasMotionActivityPermission")
            onCompletion(result)
            
        }
        motionActivityManager.stopActivityUpdates()
        
    }
    
    //sempahores for safe access
    fileprivate let pedometerSemaphore = DispatchSemaphore(value: 1)
    fileprivate let rawAccelSemaphore = DispatchSemaphore(value: 1)
    fileprivate let rawGyroSemaphore = DispatchSemaphore(value: 1)
    fileprivate let dmAttitudeSemaphore = DispatchSemaphore(value: 1)
    fileprivate let dmRotationSemaphore = DispatchSemaphore(value: 1)
    fileprivate let dmGravitySemaphore = DispatchSemaphore(value: 1)
    fileprivate let dmUserAccelSemaphore = DispatchSemaphore(value: 1)
    fileprivate let chestStrapSemaphore = DispatchSemaphore(value: 1)
    fileprivate let heartRateSemaphore = DispatchSemaphore(value: 1)
    fileprivate let locationSemaphore = DispatchSemaphore(value: 1)
    
    
    //separate sempahore for streaming, only
    fileprivate let streamSemaphore = DispatchSemaphore(value: 1)
    
    fileprivate let semaphores: [DispatchSemaphore]
    
    //iOS only variables
    var chestStrapHRItems = [ChestStrapHRPayload]()
    var locationItems = [LocationPayload]()
    
    //Watch only variables
    var heartRateItems = [[HeartRatePayload]]()
    #if os(watchOS)
    lazy var healthStore: HKHealthStore = HKHealthStore()
    #endif
    
}

//MARK: - iOS only functions
#if os(iOS)
extension MotionController {
    
    func stream(removeCurrentItems: Bool = true) {
        streamHelper(removeCurrentItems: removeCurrentItems)
    }

    func startChestStrapUpdates() {
        
        ChestStrapManager.shared.startCollecting { [weak self] (heartRate) in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.chestStrapSemaphore.wait()
            
            let payload = ChestStrapHRPayload(with: Double(heartRate))
            payload.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer)
            strongSelf.chestStrapHRItems.append(payload)
            
            strongSelf.chestStrapSemaphore.signal()
        }
    }
    
    func stopChestStrapUpdates() {
        ChestStrapManager.shared.stopCollecting()
    }
    
    func startLocationUpdates() {
        LocationManager.shared.startCollecting { [weak self] (locationData) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.locationSemaphore.wait()
            
            let payload = LocationPayload(with: locationData)
            payload.setTimestamp(wallTime: strongSelf.currentTime, timer: strongSelf.timer)
            strongSelf.locationItems.append(payload)
            
            strongSelf.locationSemaphore.signal()
            
        }
    }
    
    func stopLocationUpdates() {
        LocationManager.shared.stopCollecting()
    }

    
}
#endif

//MARK: - Watch only functions
#if os(watchOS)
extension MotionController {
    
    func stream(removeCurrentItems: Bool = true) {
        saveHKItems(fromDate: lastStreamDate) { [weak self] in
            self?.streamHelper(removeCurrentItems: removeCurrentItems)
        }
    }
    
    func saveHKItems(fromDate startDate: Date = Date(), onCompletion : (()->Void)? = nil) {
        
        readHKData(forType: HKObjectType.quantityType(forIdentifier: .heartRate)!, fromDate: startDate, onCompletion)
        
    }
    
    fileprivate func readHKData(forType quantityType: HKQuantityType, fromDate startDate: Date = Date(), _ onCompletion : (()->Void)? = nil) {
        
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictEndDate )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let query = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { [weak self] (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            
            self?.didReceiveQueryResult(query, sampleObjects, deletedObjects, newAnchor: newAnchor, error)
            onCompletion?()
        }
        
        healthStore.execute(query)
    }
    
    fileprivate func didReceiveQueryResult(_ query: HKAnchoredObjectQuery, _ sampleObjects: [HKSample]?, _ deletedObjects: [HKDeletedObject]?, newAnchor: HKQueryAnchor?, _ error: Error?) {
        
        guard let results = sampleObjects as? [HKQuantitySample], error == nil else { // there was an error reading from healthKit
            return
        }
        
        var hrItems = [HeartRatePayload]()
        results.forEach { (sample: HKQuantitySample) in
            hrItems.append(HeartRatePayload(fromData: sample))
        }
        
        heartRateSemaphore.wait()
        heartRateItems.append(hrItems)
        heartRateSemaphore.signal()
    }
    
}
#endif
