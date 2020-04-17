//
//  SessionManager.swift
//  Vasctrac
//
//  Created by Developer on 5/3/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import RealmSwift
import SAMKeychain
import SwiftyJSON

class SessionManager {
    
    static let shared = SessionManager()
    
    // Get the default Realm
    let realm = try! Realm()
    
    // MARK: - Name the user introduces in consent signing
    var userSignatureFirstName : String? = nil
    var userSignatureLastName : String? = nil
    var userConsentToPublicData : Bool? = nil
    
    // MARK: - User
    fileprivate lazy var _currentUser : User? = {
        return self.realm.objects(User.self).first
    }()
    
    var currentUser : User? {
        get {
            return _currentUser
        }
        set(newValue) {
            if newValue == nil { // delete user
                try! realm.write {
                    if let user = _currentUser {
                        realm.delete(user)
                        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.EID)
                        UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.UserId)
                    }
                }
            } else {
                try! realm.write {
                    if let newValue = newValue, let newUserId = newValue.userId {
                        if realm.object(ofType: User.self, forPrimaryKey: newUserId) == nil {
                            realm.add(newValue)
                            UserDefaults.standard.set(newValue.userId, forKey: Constants.UserDefaults.UserId)
                            UserDefaults.standard.set(newValue.eId, forKey: Constants.UserDefaults.EID)
                        }
                    }
                }
            }
            _currentUser = newValue
        }
    }
    
    //This reference to the userId is based of UserDefaults instead of Realm
    //When needed, only use this reference if you need to access the userID from a background thread.
    //Otherwise, use Realm reference above when thread safe.
    var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaults.UserId)
        }
    }
    
    //This reference to the eId is based of UserDefaults instead of Realm. See above.
    var eId: String? {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaults.EID)
        }
    }
    
    // MARK : - Token
    fileprivate lazy var _accessToken : String? = {
        return SAMKeychain.password(forService: Constants.Keychain.AppIdentifier,
                                             account: Constants.Keychain.TokenIdentifier)
    }()
    var accessToken : String? {
        get {
            return _accessToken
        }
        
        set(newValue) {
            _accessToken = newValue
            
            if newValue == nil { // delete user token
                SAMKeychain.deletePassword(forService: Constants.Keychain.AppIdentifier,
                                                    account: Constants.Keychain.TokenIdentifier)
            } else {
                SAMKeychain.setPassword(newValue!, forService: Constants.Keychain.AppIdentifier,
                                       account: Constants.Keychain.TokenIdentifier)
            }
        }
    }
    var hasAccessToken: Bool {
        return accessToken != nil
    }
    
    // MARK: - Initialization
    
    init() {
        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(resetAccounts),
                                                         name: NSNotification.Name(rawValue: Constants.Notification.SessionReset),
                                                         object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionExpired),
                                               name: NSNotification.Name(rawValue: Constants.Notification.SessionExpired),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.SessionExpired), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.SessionReset), object: nil)
    }
    
    func clearKeychainData() {
        
        // remove token from keychain
        if self.accessToken != nil {
            self.accessToken = nil
        }
        
    }
    
    func clearAppData(forceNavigation: Bool = false, onCompletion: (()->Void)? = nil) {
        clearKeychainData()
        
        //reset UserDefaults
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        UserDefaults.standard.synchronize()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        DispatchQueue.main.async { [weak self] in
            
            // delete user
            if self?.currentUser != nil {
                self?.currentUser = nil
            }
            
            //delete all from realm
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            
            onCompletion?()
            
        }
    }
    
    @objc func resetAccounts() {
        clearAppData(forceNavigation: false)
    }
    
    @objc func sessionExpired() {
        clearAppData(forceNavigation: true)
    }
    
    // MARK: - Convenience
    func mapUser(_ data: [String: Any]) -> User? {
        
        let json = JSON(data)
        
        guard json["e_id"] != JSON.null else {
            return nil
        }
        
        guard json["ID"] != JSON.null else {
            return nil
        }
        
        var userDict = json.dictionaryObject!
        userDict["userId"] = json["ID"].numberValue.stringValue
        userDict["eId"] = json["e_id"].stringValue
        
        return User(value: userDict)
    }
    
    func toMap() -> [String:Any] {
        guard let currentUser = SessionManager.shared.currentUser else {
            return [String:Any]()
        }
        
        return ["userId":currentUser.userId, "eId": currentUser.eId]
    }
    
    func toThreadSafeMap() -> [String:Any] {
        guard let userId = SessionManager.shared.userId, let eId = SessionManager.shared.eId else {
            return [String:Any]()
        }
        
        return ["userId": userId, "eId": eId]
    }
    
    // MARK: - User Defaults
    
    func checkFirstRun() {
        if self.getFirstRun() == nil { // app never run before
            
            if SessionManager.shared.currentUser == nil { //if we have no user...
                UIApplication.shared.applicationIconBadgeNumber = 0
                self.clearKeychainData() //clear the keychain
            }
            
            self.setFirstRun()
        }
    }
    
    fileprivate func setFirstRun() {
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.FirstRun)
        UserDefaults.standard.synchronize()
    }
    
    func getFirstRun() -> Bool? {
        return UserDefaults.standard.value(forKey: Constants.UserDefaults.FirstRun) as? Bool
    }
    
}
