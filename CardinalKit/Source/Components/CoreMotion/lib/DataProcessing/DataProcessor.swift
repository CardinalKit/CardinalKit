//
//  DataProcessor.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 3/22/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation
import Zip

enum DataProcessorStep: Int {
    case processing = 0
    case packaging
    case finished
    case errorProcessing
}

protocol DataProcessorDelegate {
    func dataProcessor(didBegin step: DataProcessorStep)
    func dataProcessor(didFinishWith package: Package)
    func dataProcessor(didFail lastStep: DataProcessorStep, _ failedOperations: [String])
}

class DataProcessor {
    
    enum MotionExportFiles : String {
        case pedo = "PEDO.csv"
        case rawAccel = "RAW_ACCEL.csv"
        case rawGyro = "RAW_GYRO.csv"
        case dmAttitude = "DM_ATTITUDE.csv"
        case dmRotationRate = "DM_ROTATION_RATE.csv"
        case dmGravity = "DM_GRAVITY.csv"
        case dmUserAcceleration = "DM_USER_ACCELERATION.csv"
        case heartRate = "HEART_RATE_%d.csv"
        case chestStrap = "CHEST_STRAP.csv"
        case location = "LOCATION.csv"
        
        static let all = [pedo, rawAccel, rawGyro, dmAttitude, dmRotationRate, dmGravity, dmUserAcceleration, heartRate, chestStrap, location]
    }
    
    enum Device : String {
        case phone = "IPHONE"
        case watch = "WATCH"
    }
    
    fileprivate var currentStep: DataProcessorStep = .processing
    fileprivate var failedOperations = [String]()
    fileprivate var payloadDirectory: URL?
    fileprivate var isPackaging: Bool = false
    fileprivate var csvQueue: OperationQueue?
    
    fileprivate lazy var filePrefix: String = {
        var prefix = ""
        
        #if os(iOS)
        prefix += (SessionManager.shared.userId ?? "") + "_"
        #endif
        
        prefix += motionData.syncId + "_"
        prefix += Date().stringWithFormat("yyyyMMddHHmmss") + "_"
        
        prefix += (motionData.device ?? .phone).rawValue
        
        if !tag.isEmpty {
            prefix += "_\(tag)"
        }
        
        return prefix
    }()
    
    let motionData: MotionDataResult
    let delegate: DataProcessorDelegate?
    var tag = ""
    
    init(_ motionData: MotionDataResult, delegate: DataProcessorDelegate? = nil) {
        self.motionData = motionData
        self.delegate = delegate
    }
    
    func process() {
        step(.processing)
        
        payloadDirectory = CacheManager.shared.getTemporaryFolder(filePrefix)
        
        if !failedOperations.isEmpty {
            failedOperations = [String]()
        }
        
        csvQueue = OperationQueue()
        csvQueue?.qualityOfService = .userInitiated
        csvQueue?.maxConcurrentOperationCount = 7
        
        guard var csvOperations = listOperations(usingData: motionData) else {
            processFailure()
            return
        }
        
        let doneOperation = Operation()
        csvOperations.forEach({ (operation) in
            doneOperation.addDependency(operation)
        })
        doneOperation.completionBlock = { [weak self] in
            VLog("Operations done! Left: %@", self?.csvQueue?.operationCount ?? -1)
            self?.packageAndSend()
        }
        
        csvOperations.append(doneOperation)
        csvQueue?.addOperations(csvOperations, waitUntilFinished: false)
    }
    
    fileprivate func packageAndSend() {
        guard let payloadDirectory = payloadDirectory, !isPackaging else {
            processFailure()
            return
        }
        
        step(.packaging)
        isPackaging = true
        
        let prefix = self.filePrefix //obtain prefix in advance
            
        do {
            
            let package = Package(prefix + ".zip", type: .sensorData)
            let storeLocation = try package.store()
            
            try Zip.zipFiles(paths: [payloadDirectory], zipFilePath: storeLocation, password: nil, compression: .DefaultCompression, progress: nil)
            
            self.send(package)
            self.isPackaging = false
            
        } catch {
            self.failedOperations.append("[ZIP] error with compression and cleanup")
            self.isPackaging = false
            self.processFailure()
        }
        
    }
    
    fileprivate func send(_ package: Package) {
        if let payloadDirectory = payloadDirectory {
            CacheManager.shared.deleteCache(atURL: payloadDirectory)
        }
        
        guard package.hasData() else {
            failedOperations.append("[ZIP] output file was not created; likely a permissions failure")
            delegate?.dataProcessor(didFail: currentStep, failedOperations)
            return
        }
        
        delegate?.dataProcessor(didFinishWith: package)
    }
    
    fileprivate func processFailure() {
        if let payloadDirectory = payloadDirectory {
            CacheManager.shared.deleteCache(atURL: payloadDirectory)
        }
        
        delegate?.dataProcessor(didFail: currentStep, failedOperations)
    }
    
    fileprivate func step(_ step: DataProcessorStep) {
        guard let delegate = delegate else {
            fatalError("You must set the DataProcessor delegate in order to retrieve results.")
        }
        
        self.currentStep = step
        delegate.dataProcessor(didBegin: step)
    }
    
}

//CSV Operations
extension DataProcessor {
    
    fileprivate func listOperations(usingData motionData: MotionDataResult) -> [Operation]? {
        
        guard let payloadDirectory = payloadDirectory else {
            processFailure()
            return nil
        }
        
        var operations = [Operation]()
        
        for item in MotionExportFiles.all {
            let fileName = filePrefix + "_" + item.rawValue
            let filePath = payloadDirectory.appendingPathComponent(fileName)
            
            switch item {
            case .pedo:
                let pedo = motionData.pedometerItems
                if !pedo.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.pedometerItems)
                    operations.append(operation)
                }
                break
            case .rawAccel:
                let accel = motionData.rawAccelerationItems
                if !accel.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.rawAccelerationItems)
                    operations.append(operation)
                }
                break
            case .rawGyro:
                let gyro = motionData.rawGyroItems
                if !gyro.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.rawGyroItems)
                    operations.append(operation)
                }
                break
            case .dmAttitude:
                let attitude = motionData.deviceMotionAttitude
                if !attitude.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.deviceMotionAttitude)
                    operations.append(operation)
                }
                break
            case .dmRotationRate:
                let rotation = motionData.deviceMotionRotation
                if !rotation.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.deviceMotionRotation)
                    operations.append(operation)
                }
                break
            case .dmGravity:
                let gravity = motionData.deviceMotionGravity
                if !gravity.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.deviceMotionGravity)
                    operations.append(operation)
                }
                break
            case .dmUserAcceleration:
                let userAccel = motionData.deviceMotionUserAcceleration
                if !userAccel.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.deviceMotionUserAcceleration)
                    operations.append(operation)
                }
                break
            case .heartRate:
                for (index, values) in motionData.heartRateItems.enumerated() {
                    let formatName = String(format: fileName, index)
                    let formatPath = payloadDirectory.appendingPathComponent(formatName)
                    
                    let operation = createOperation(usingPath: formatPath, andSource: values)
                    operations.append(operation)
                }
            case .chestStrap:
                let chestStrapItems = motionData.chestStrapItems
                if !chestStrapItems.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: chestStrapItems)
                    operations.append(operation)
                }
                break
            case .location:
                let locationItems = motionData.locationItems
                if !locationItems.isEmpty {
                    let operation = createOperation(usingPath: filePath, andSource: motionData.locationItems)
                    operations.append(operation)
                }
                break
            }
            
        }
        return operations
    }
    
    fileprivate func createOperation<T : CSVExporting>(usingPath path: URL, andSource source: [T]) -> CSVOperation<T> {
        
        let operation = CSVOperation(filePath: path, source: source)
        operation.completionBlock = { [weak self] in
            
            if operation.finishedState == .success {
                //print("File saved @ \(operation.getPath())")
            } else {
                self?.failedOperations.append(operation.getPath())
                //print("File failed to save \(operation.finishedState) @ \(operation.getPath())")
            }
            
        }
        
        return operation
    }
    
}
