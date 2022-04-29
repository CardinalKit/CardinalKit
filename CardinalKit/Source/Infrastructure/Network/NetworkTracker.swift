//
//  NetworkTracker.swift
//  CardinalKit
//
//  Copy from Santiago Gutierrez on 7/23/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import ReachabilitySwift

class NetworkTracker {
    static let shared = NetworkTracker()
    fileprivate let reachability = Reachability()!
    
    init(){
        initListeners()
    }
    
    deinit{
        reachability.stopNotifier()
    }
    
}

extension NetworkTracker {
    fileprivate func initListeners() {
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.notify()
            }
        }
        do {
            try reachability.startNotifier()
        } catch {
            VError("Unable to start network notifier: %@", error.localizedDescription)
        }
    }
    
    func notify(){
        checkPending()
        checkProcessing()
    }
    
    fileprivate func checkPending() {
        let pending = getPendingRequests()
        guard !pending.isEmpty else {
            return
        }
        for item in pending {
            do {
                try item.perform()
            } catch {
                VError("%@", error.localizedDescription)
            }
        }
    }
    
    fileprivate func getPendingRequests()  -> [NetworkRequestObject] {
        if let items = CKApp.instance.options.localDBDelegate?.getNetworkItemsByFilter(filterQuery: "processing == false AND sentOn == nil"){
            return items
        }
        return []
    }
    
    fileprivate func checkProcessing() {
        let processing = getProcesingRequests()
        guard !processing.isEmpty else {
            return
        }
        for item in processing {
            let waitThreshold = Date().addingTimeInterval(-60*10) //10 mins
            if let lastAttempt = item.lastAttempt, lastAttempt > waitThreshold {
                continue
            }
            DispatchQueue.main.async {
                item.fail()
            }
        }
    }
    
    fileprivate func getProcesingRequests()  -> [NetworkRequestObject] {
        if let items = CKApp.instance.options.localDBDelegate?.getNetworkItemsByFilter(filterQuery: "processing == true"){
            return items
        }
        return []
    }
}
