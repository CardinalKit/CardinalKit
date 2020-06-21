//
//  UploadManager.swift
//  VascTrac
//
//  Copyright © 2018 VascTrac. All rights reserved.
//

import Foundation

class UploadManager: NSObject {
    
    public static let shared = UploadManager()
    
    fileprivate var sessionMutex = NSLock()
    fileprivate var backgroundHandler: (()->Void)?
    
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: Constants.Keychain.AppIdentifier)
        config.allowsCellularAccess = true
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 15
        config.sessionSendsLaunchEvents = true
        config.shouldUseExtendedBackgroundIdleMode = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func upload(file: URL, to url: URL, uuid: String) {
        VLog("Uploading file to url %{public}@", file.path, url.absoluteString)
        self._upload(file: file, to: url, uuid: uuid)
    }
    
}

extension UploadManager {
    
    fileprivate func _upload(file: URL, to url: URL, uuid: String) {
        var request = _request(to: url)
        request.addValue("attachment; filename=\"\(file.lastPathComponent)\"", forHTTPHeaderField: "Content-Disposition")
        
        let task = session.uploadTask(with: request, fromFile: file)
        task.taskDescription = uuid
        task.resume()
    }
    
    fileprivate func _request(to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return OAuth2Handler.adapt(request)
    }
    
}

extension UploadManager {
 
    func add(handler: @escaping () -> Void) {
        sessionMutex.lock()
        defer { sessionMutex.unlock() }
        
        self.backgroundHandler = handler
    }
    
    func handler() {
        sessionMutex.lock()
        defer { sessionMutex.unlock() }
        
        self.backgroundHandler?()
        self.backgroundHandler = nil
    }
    
}


extension UploadManager {
 
    func cancel(_ request: NetworkDataRequest) {
        let requestId = request.id //thread-safe, realm-free, copy
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            for item in uploadTasks {
                let task = item as URLSessionTask
                guard let taskRequest = NetworkDataRequest.findNetworkRequest(task) else {
                    continue
                }
                
                if taskRequest.id == requestId {
                    item.cancel() //we found our request, so stop running it.
                    return
                }
            }
        }
    }
    
}


extension UploadManager: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        VLog("urlSessionDidFinishEvents forBackgroundURLSession")
        self.handler()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let request = NetworkDataRequest.findNetworkRequest(task) else {
            VError("Unable to parse urlSession task %@", task.debugDescription)
            return
        }
        
        guard let response = task.response as? HTTPURLResponse else {
            request.fail()
            return
        }
        
        if let error = error, !(200 ... 299).contains(response.statusCode) {
            //when the phone is locked, there is sometimes an error that is triggered despite the network task completing successfully. 
            VError("urlSession task didCompleteWithError %@", error.localizedDescription)
        }
        
        request.mark(response.statusCode)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        let result = String(data: data, encoding: .utf8) ?? "(no result data)"
        if let response = dataTask.response as? HTTPURLResponse, (200 ... 299).contains(response.statusCode) {
            VLog("urlSession dataTask %@", result)
        } else {
            VError("urlSession dataTask %@", result)
        }
    }
    

}
