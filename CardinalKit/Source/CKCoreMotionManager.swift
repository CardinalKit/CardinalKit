//
//  CKCoreMotionManager.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 12/21/20.
//

import Foundation

public class CKCoreMotionManager : NSObject {
    
    public static let shared = CKCoreMotionManager()
    
    let motionManager = MotionController()
    
    public var isActive: Bool {
        get {
            return motionManager.isActive
        }
    }
    
    public var delegate: MotionDelegate? {
        didSet {
            motionManager.delegate = delegate
        }
    }
    
    public override init() {
        super.init()
        
        motionManager.syncId = UUID().uuidString
        motionManager.automaticStreaming = true
        motionManager.device = .phone
    }
    
    public func start() {
        motionManager.start()
    }
    
    public func stop() {
        motionManager.stop()
        motionManager.stream()
    }
    
}
