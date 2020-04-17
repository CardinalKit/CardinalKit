//
//  DataProcessorOperation.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

class DataProcessorOperation: DAOperation, DataProcessorDelegate {
    
    fileprivate let data: MotionDataResult
    fileprivate let streamIndex: Int
    
    var hasFailed: Bool = false
    var dataProcessor: DataProcessor?
    
    init(using data: MotionDataResult, andIndex index: Int = 0) {
        self.data = data
        self.streamIndex = index
    }
    
    override func main() {
        guard !isCancelled else {
            finish(true)
            return
        }
        
        self.startExecution()
        
        dataProcessor = DataProcessor(data, delegate: self)
        if streamIndex > 0 {
            dataProcessor?.tag = "\(streamIndex)"
        }
        dataProcessor?.process()
    }
    
}

extension DataProcessorOperation {
    
    func dataProcessor(didFinishWith package: Package) {
        VLog("dataProcessor didFinishWith %@", package.description)
        
        #if os(iOS)
        do {
            try NetworkDataRequest.send(package)
        } catch {
            VError("Unable to process package %@", error.localizedDescription)
        }
        #endif
        
        #if os(watchOS)
        if let zipFilePath = try? package.store() {
            TransferManager.shared.transfer(file: zipFilePath)
            WatchConnectivityManager.shared.sendMessage(message: ["filePath":zipFilePath.absoluteString])
        } else {
            VError("Unable to resolve zipFilePath for package %@", package.description)
        }
        #endif
        
        self.finishExecution()
    }
    
    func dataProcessor(didFail lastStep: DataProcessorStep, _ failedOperations: [String]) {
        VError("dataProcessor didFail %@", lastStep.rawValue, failedOperations.count)
        
        self.hasFailed = true
        self.finishExecution()
    }
    
    func dataProcessor(didBegin step: DataProcessorStep) {}
    
}
