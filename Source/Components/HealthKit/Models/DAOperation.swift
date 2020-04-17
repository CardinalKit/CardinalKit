//
//  DAOperation.swift
//  VascTrac
//
//  Source: http://agostini.tech/2017/07/30/understanding-operation-and-operationqueue-in-swift/
//

import Foundation

class DAOperation: Operation {
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    func startExecution() {
        executing(true)
    }
    
    func finishExecution() {
        executing(false)
        finish(true)
    }
    
}
