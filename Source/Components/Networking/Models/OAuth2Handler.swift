//
//  OAuth2Handler.swift
//  VascTrac
//
//  Created by Santiago Gutierrez on 5/17/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import Foundation
import UIKit

//request retrying protocol
class OAuth2Handler {
    
    private let lock = NSLock()
    
    private var accessToken: String
    
    //private var requestsToRetry: [RequestRetryCompletion] = []
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return OAuth2Handler.adapt(urlRequest, token: accessToken)
    }
    
    class func adapt(_ urlRequest: URLRequest, token accessToken: String) -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(Constants.Network.currentServerUrl) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            if let deviceId = UIDevice.current.identifierForVendor?.uuidString {
                urlRequest.setValue(deviceId, forHTTPHeaderField: "X-DeviceId")
            }
            
            if let release = Bundle.main.releaseVersionNumber,
                let build = Bundle.main.buildVersionNumber {
                let appVersion = "\(release).\(build)"
                urlRequest.setValue(appVersion, forHTTPHeaderField: "X-AppVersion")
            }
            
            let localTimeZone = String(describing: TimeZone.current).components(separatedBy: " ")[0]
            urlRequest.setValue(localTimeZone, forHTTPHeaderField: "X-Device-Timezone")
            
            if let language = Locale.current.languageCode {
                urlRequest.setValue(language, forHTTPHeaderField: "X-Device-Language") //fi, sv, en
            }
            
            return urlRequest
        }
        
        return urlRequest
    }
    
}
