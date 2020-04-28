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
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return OAuth2Handler.adapt(urlRequest)
    }
    
    class func getHeaders() -> [String:String]? {
        return CKApp.instance.networkDelegate?.getHeaders()
    }
    
    class func isWhitelisted(url: String) -> Bool {
        guard let whitelistUrls = CKApp.instance.networkDelegate?.getWhitelistURLs() else {
            return false
        }
        
        return (whitelistUrls.filter { url.hasPrefix($0) }.count != 0)
    }
    
    class func adapt(_ urlRequest: URLRequest) -> URLRequest {
        if let source = urlRequest.url?.absoluteString, isWhitelisted(url: source) {
            
            var urlRequest = urlRequest
            
            if let headers = getHeaders() {
                for (key, value) in headers {
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            
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
        } else {
            VError("URL is NOT white-listed by project.")
        }
        
        return urlRequest
    }
    
}
