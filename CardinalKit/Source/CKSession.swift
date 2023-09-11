//
//  CKSession.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation
import Security

public class CKSession {
    
    public static let shared = CKSession()
    
    public var userId: String? {
        get {
            return SessionManager.shared.userId
        }
        set {
            SessionManager.shared.userId = newValue
        }
    }
    
    public class func getSecure(key: String) -> String? {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let result = String(data: data, encoding: .utf8) {
            return result
        }
        
        return nil
    }
    
    public class func putSecure(value: String?, forKey key: String) {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(deleteQuery as CFDictionary)
        
        if let value = value, let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    public class func removeSecure(key: String) {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

extension CKSession {
    
    public func getRootCollection() -> String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "/studies/\(bundleId)/users/"
        }
        
        return nil
    }
    
    public func getAuthCollection() -> String? {
        if let userId = userId,
            let root = getRootCollection() {
            return "\(root)\(userId)/"
        }
        
        return nil
    }
    
}
