//
//  TimerController.swift
//  AstraZeneca
//
//  Created by Santiago Gutierrez on 12/5/17.
//  Copyright © 2017 VascTrac. All rights reserved.
//

import Foundation

public protocol TimerDelegate {
    func tick(_ timer: TimerController)
    func tickMinute(_ timer: TimerController)
    func limitReached()
}

public class TimerController : NSObject {
    
    public var elapsedSeconds: Int {
        get {
            return Int(elapsedTime)
        }
    }
    
    var timerLimit: Int = -1
    var elapsedTime: Double = 0.0
    var tickInterval: TimeInterval = 1.0
    var delegate: TimerDelegate?
    
    var startDate: Date {
        return Date(timeIntervalSinceReferenceDate: startTime)
    }
    
    fileprivate var startTime: Double = 0.0
    fileprivate var timer: Timer?
    fileprivate var minuteTimer: Timer?
    
    fileprivate var endDate: Date?
    
    
    fileprivate var reachedLimit: Bool {
        return elapsedSeconds >= timerLimit
    }
    
    fileprivate var isRunning: Bool {
        return timer?.isValid ?? false
    }
    
    convenience init(tickInterval: TimeInterval = 1.0) {
        self.init()
        self.tickInterval = tickInterval
    }
    
    func start(withDate startDate: Date = Date()) {
        //starting over, reset variables
        startTime = startDate.timeIntervalSinceReferenceDate
        endDate = nil
        elapsedTime = 0.0
        
        //start timer
        timer = Timer.scheduledTimer(timeInterval: tickInterval, target: self, selector: #selector(TimerController.advanceTimer(timer:)), userInfo: nil, repeats: true)
        minuteTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(TimerController.minuteTimer(timer:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        guard isRunning else {
            return
        }
        
        endDate = Date()
        timer?.invalidate()
        minuteTimer?.invalidate()
    }
    
    @objc func advanceTimer(timer: Timer) -> Double  {
        elapsedTime = Date().timeIntervalSinceReferenceDate - startTime
        delegate?.tick(self)
        
        if reachedLimit {
            delegate?.limitReached()
        }
        
        return elapsedTime
    }
    
    @objc func minuteTimer(timer: Timer) {
        delegate?.tickMinute(self)
    }
    
}
