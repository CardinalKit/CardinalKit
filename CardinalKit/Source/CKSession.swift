//
//  CKSession.swift
//  CardinalKit
//
//  Created by Santiago Gutierrez on 4/24/20.
//

import Foundation
import SAMKeychain

public class CKSession {
    
    public class func getSecure(key: String) -> String? {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        return SAMKeychain.password(forService: service, account: account)
    }
    
    public class func putSecure(value: String?, forKey key: String) {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        if value == nil {
            SAMKeychain.deletePassword(forService: service, account: account)
        } else {
            SAMKeychain.setPassword(value!, forService: service, account: account)
        }
    }
    
    public class func removeSecure(key: String) {
        let service = "\(Constants.Keychain.AppIdentifier)-\(key)"
        let account = Constants.Keychain.TokenIdentifier
        SAMKeychain.deletePassword(forService: service, account: account)
    }
    
}
