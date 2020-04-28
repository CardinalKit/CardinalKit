//
//  SyncManager.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 12/20/17.
//  Copyright © 2017 VascTrac. All rights reserved.
//

import Foundation

enum SyncOptions: String {
    case everything = "edu.stanford.vasctrac.sync.everything"
    case highPriority = "edu.stanford.vasctrac.sync.priority"
    
    case surveys = "edu.stanford.vasctrac.sync.surveys"
    case walktests = "edu.stanford.vasctrac.sync.walktests"
    case events = "edu.stanford.vasctrac.sync.events"
}

@objc protocol SyncDelegate : class {
    @objc optional func didSyncWalkTests()
    @objc optional func didSyncSurveys()
    @objc optional func didSyncEvents()
    @objc optional func didCompleteSync()
}

class SyncManager {
    
    static let shared = SyncManager()
    
    fileprivate var delegates = [SyncDelegate]()
    fileprivate var syncDay : Date? = nil
    
    //var isRunning = false
    
    let semaphore = DispatchSemaphore(value: 1)
    
    init() {
        
    }
    
    func sync(_ options: SyncOptions = .everything) {
        
        guard SessionManager.shared.userId != nil else {//&& !isRunning else {
            return //must be logged in to sync
        }
        
        //isRunning = true
        
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        
        var operations = [Operation]()
        let doneOperation = Operation()
        var results = [String:Bool]()
        
        /* if options == .everything || options == .highPriority || options == .walktests {
            let newOperation = SyncWalkTests()
            doneOperation.addDependency(newOperation)
            operations.append(newOperation)
            
            newOperation.completionBlock = { [weak self] in
                results[SyncOptions.walktests.rawValue] = newOperation.isDirty
                
                DispatchQueue.main.async { [weak self] in
                    self?.didSyncWalkTests(withResults: results)
                }
            }
        }
        
        if options == .everything || options == .surveys {
            let newOperation = SyncSurveys()
            doneOperation.addDependency(newOperation)
            operations.append(newOperation)
            
            newOperation.completionBlock = { [weak self] in
                results[SyncOptions.surveys.rawValue] = newOperation.isDirty
                
                DispatchQueue.main.async { [weak self] in
                    self?.didSyncSurveys(withResults: results)
                }
            }
        }
        
        if options == .everything || options == .highPriority || options == .events {
            let newOperation = SyncEvents()
            doneOperation.addDependency(newOperation)
            operations.append(newOperation)
            
            newOperation.completionBlock = { [weak self] in
                results[SyncOptions.events.rawValue] = newOperation.isDirty
                
                DispatchQueue.main.async { [weak self] in
                    self?.didSyncEvents(withResults: results)
                }
            }
        } */
        
        doneOperation.completionBlock = { [weak self] in
            //self?.isRunning = false
            
            DispatchQueue.main.async { [weak self] in
                self?.didCompleteSync(withResults: results)
            }
        }
        
        operations.append(doneOperation)
        operationQueue.addOperations(operations, waitUntilFinished: false)
        
    }
    
}

//Helper methods for delegates
extension SyncManager {
    
    func addDelegate(_ newDelegate: SyncDelegate) {
        if delegates.index(where: { $0 === newDelegate }) == nil {
            delegates.append(newDelegate)
        }
    }
    
    func removeDelegate(_ delegate: SyncDelegate) {
        if let index = delegates.index(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }
    }
    
    func didSyncWalkTests(withResults results: [String:Bool]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Sync.walkTestCompleted), object: nil, userInfo: results)
        delegates.forEach { (delegate) in
            delegate.didSyncWalkTests?()
        }
    }
    
    func didSyncSurveys(withResults results: [String:Bool]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Sync.surveysCompleted), object: nil, userInfo: results)
        delegates.forEach { (delegate) in
            delegate.didSyncSurveys?()
        }
    }
    
    func didSyncEvents(withResults results: [String:Bool]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Sync.eventsCompleted), object: nil, userInfo: results)
        delegates.forEach { (delegate) in
            delegate.didSyncEvents?()
        }
    }
    
    func didCompleteSync(withResults results: [String:Bool]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.Sync.completed), object: nil, userInfo: results)
        delegates.forEach { (delegate) in
            delegate.didCompleteSync?()
        }
    }
    
}
