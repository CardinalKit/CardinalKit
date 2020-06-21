//
//  DataStreamer.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 4/24/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

class DataStreamer {
    
    static let shared = DataStreamer()
    
    var hasPendingItems: Bool {
        get {
            return !pendingData.isEmpty || operationQueue.operationCount > 0
        }
    }
    
    fileprivate var pendingData = [MotionDataResult]()
    fileprivate var pendingSemaphore = DispatchSemaphore(value: 1)
    fileprivate var sessionStreamCount = 0
    
    fileprivate lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    func streamFromCache() {
        guard !pendingData.isEmpty else {
            return
        }
        
        guard canWrite() else {
            return
        }
        
        pendingData.forEach { (payload) in
            stream(payload)
        }
    }
    
    func stream(_ data : MotionDataResult) {
        sessionStreamCount += 1
        let streamOperation = DataProcessorOperation(using: data, andIndex: sessionStreamCount)
        streamOperation.completionBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if streamOperation.hasFailed { //failed
                strongSelf.addPending(data)
            } else { //succeeded
                strongSelf.removePending(data)
            }
        }
        
        if canWrite() {
            operationQueue.addOperation(streamOperation)
        } else {
            VError("Cannot write to filesystem. Adding stream data to pending queue.")
            addPending(data)
        }
    }
    
    func clearSession() {
        //should be done when starting a new data streaming operation
        //if and only if said operation is not appending data to a
        //previous one
        
        VLog("Clearing session...")
        sessionStreamCount = 0
    }
    
}

extension DataStreamer {
    
    fileprivate func addPending(_ data: MotionDataResult) {
        pendingSemaphore.wait()
        if !pendingData.contains(data) {
            pendingData.append(data)
        }
        pendingSemaphore.signal()
    }
    
    fileprivate func removePending(_ data: MotionDataResult) {
        pendingSemaphore.wait()
        if let index = pendingData.index(of: data) {
            pendingData.remove(at: index)
        }
        pendingSemaphore.signal()
    }
    
    //this generally returns false if the screen is locked
    fileprivate func canWrite() -> Bool {
        guard let path = CacheManager.shared.getPackageContainer(fileType: .sensorData) else {
            return false
        }
        
        let filePath = path.appendingPathComponent("vt.lock")
        
        let text = "[\(Date().ISOStringFromDate())]"
        
        do {
            try text.write(to: filePath, atomically: false, encoding: .utf8)
            return true
        } catch {
            VError("canWrite() false w/ error: %@", error.localizedDescription)
            return false
        }
    }
    
}
