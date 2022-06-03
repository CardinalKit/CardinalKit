//
//  VLog.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation
import os.log

func VError(_ message: StaticString, _ args: CVarArg..., category: String = #function) {
    VLogger(.error, message, args, category)
}

func VLog(_ message: StaticString, _ args: CVarArg..., category: String = #function) {
    VLogger(.info, message, args, category)
}

func VLogger(_ type: OSLogType, _ message: StaticString, _ args: CVarArg..., category: String = #function) {
    
    #if os(watchOS)
    //let logWatch = category + " - " + String(format: "\(message)", args)
    //WatchConnectivityManager.shared.sendMessage(message: ["os.log":logWatch])
    #endif
    
    let log = OSLog(subsystem: "\(Constants.app).logging", category: category)
    if #available(iOS 12.0, *), #available(watchOSApplicationExtension 5.0, *) {
        os_log(type, log: log, message, args)
    } else {
        os_log(message, log: log, type: type, args)
    }
}
