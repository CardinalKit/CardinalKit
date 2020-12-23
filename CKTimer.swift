//
//  CKTimer.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 12/22/20.
//

import Foundation

public class CKTimer: NSObject {
    
    fileprivate let timer = TimerController()
    
    public var delegate: TimerDelegate? {
        didSet {
            timer.delegate = delegate
        }
    }
    
    public override init() {
        super.init()
    }
    
    public func start(withDate startDate: Date = Date()) {
        timer.start(withDate: startDate)
    }
    
    public func stop() {
        timer.stop()
    }
    
}
