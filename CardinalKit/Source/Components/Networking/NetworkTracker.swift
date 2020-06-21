//
//  NetworkTracker.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 7/23/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import ReachabilitySwift
import RealmSwift

enum NetworkTypes: String {
    case connected = "cardinalkit.network.connected"
    case disconnected = "cardinalkit.network.disconnected"
}

class NetworkTracker {
    
    static let shared = NetworkTracker()
    
    fileprivate let reachability = Reachability()!
    fileprivate var isHealthy = false
    
    init() {
        initListeners()
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    lazy var completedResults: Results<NetworkDataRequest>? = {
        return (try? getCompletedRequests()) ?? nil
    }()
    
    lazy var pendingResults: Results<NetworkDataRequest>? = {
        return (try? getPendingRequests()) ?? nil
    }()
    
    lazy var processingResults: Results<NetworkDataRequest>? = {
        return (try? getProcessingRequests()) ?? nil
    }()
    
    func notify() {
        
        checkPending()
        checkProcessing()
        checkCache()
    }
    
}

extension NetworkTracker {
    
    fileprivate func checkPending() {
        guard let pending = pendingResults, !pending.isEmpty else {
            return
        }
        
        for item in pending {
            
            do {
                try item.perform()
            } catch {
                VError("%@", error.localizedDescription)
            }
        }
        
        // sendFileSnapshot()
    }
    
    fileprivate func checkProcessing() {
        guard let processing = processingResults, !processing.isEmpty else {
            return
        }
        
        for item in processing {
            let waitThreshold = Date().addingTimeInterval(-60*10) //10 mins
            if let lastAttempt = item.lastAttempt, lastAttempt > waitThreshold {
                continue
            }
            
            UploadManager.shared.cancel(item)
            item.fail()
        }
    }
    
    fileprivate func checkCache() {
        
        guard let cacheContents = CacheManager.shared.getZipContents(fileType: .sensorData), !cacheContents.isEmpty else {
            VLog("No contents on iPhone cache")
            return
        }
        
        for url in cacheContents {
         
            let package = Package(url, type: .sensorData)
            do {
                let packageRequest = try NetworkDataRequest.findNetworkRequest(package)
                if let packageRequest = packageRequest {
                    if packageRequest.status == .completed {
                        CacheManager.shared.deleteCache(atURL: url)
                    }
                } else { //packageRequest = nil
                    //if we cannot find a valid request for this file,
                    
                    //then create & send it
                    try NetworkDataRequest.send(package)
                    VLog("Couldn't find a valid request for %@, so a new one was created.", package.fileName)
                }
            } catch {
                VError("%@", error.localizedDescription)
            }
        }
    }
    
}

extension NetworkTracker {
    
    fileprivate func _sendFileSnapshot() throws {
        guard let snapshot = CacheManager.shared.createSnapshotData() else {
            return
        }
        
        do {
            let sessionEID = SessionManager.shared.userId ?? ""
            let package = try Package("\(sessionEID)_snapshot_report_\(Date().stringWithFormat("yyyyMMdd'T'HHmmss"))", type: .snapshot, data: snapshot)
            
            let store = try package.store()
            
            //TODO: send without retry (!!!)
            
            //using the APIClient because we don't actually want this request to be retried if it fails at the moment
            //APIClient.sharedClient.uploadSnapshot(usingFile: store)
            
            //try NetworkDataRequest.send(package)
            
        } catch {
            VError("%@", error.localizedDescription)
        }
    }
    
    fileprivate func sendFileSnapshot() {
        do {
            try _sendFileSnapshot()
        } catch {
            VError("%@", error.localizedDescription)
        }
    }
    
}

extension NetworkTracker {
    
    fileprivate func networkCheck() {
        guard isHealthy == false && SessionManager.shared.userId != nil else {
            return
        }
        
        //TODO: Ping health with Firebase (!!!)
        /* APIClient.sharedClient.pingHealth() { [weak self] result, error in
            self?.isHealthy = result
            
            if !result {
                AnalyticsManager.shared.log(event: .networkPingFailed)
                ErrorManager.sharedManager.showErrorOnTop("Unable to connect to VascTrac servers. Please check your internet connection.")
            } else {
                VLog("Connection to VascTrac server is healthy.")
            }
        }*/
    }
    
    fileprivate func initListeners() {
        reachability.whenReachable = { reachability in // this is called on a background thread
            
            DispatchQueue.main.async {
                self.notify()
                self.networkCheck()
                //self.reloadNetworkQueue() //TOOD: move surveys onto new system
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NetworkTypes.connected.rawValue), object: nil)
            }
            
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            VError("Unable to start network notifier: %@", error.localizedDescription)
        }
    }
    
}
    

extension NetworkTracker {

    fileprivate func getCompletedRequests() throws -> Results<NetworkDataRequest> {
        let realm = try Realm()
        return realm.objects(NetworkDataRequest.self).filter("sentOn != nil")
    }
    
    fileprivate func getPendingRequests() throws -> Results<NetworkDataRequest> {
        let realm = try Realm()
        return realm.objects(NetworkDataRequest.self).filter("processing == false AND sentOn == nil")
    }
    
    fileprivate func getProcessingRequests() throws -> Results<NetworkDataRequest> {
        let realm = try Realm()
        return realm.objects(NetworkDataRequest.self).filter("processing == true")
    }
    
}
