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

public class SessionManager {
    
    static let shared = SessionManager()
    
    // Get the default Realm
    let realm = try! Realm()
    
    //This reference to the userId is based of UserDefaults instead of Realm
    //When needed, only use this reference if you need to access the userID from a background thread.
    //Otherwise, use Realm reference above when thread safe.
    var userId: String? {
        get {
            let userId = UserDefaults.standard.string(forKey: Constants.UserDefaults.UserId)
            
            if (userId == nil) {
                let newUserId = UUID().uuidString
                UserDefaults.standard.set(newUserId, forKey: Constants.UserDefaults.UserId)
                return newUserId
            }
            
            return UserDefaults.standard.string(forKey: Constants.UserDefaults.UserId)
        }
        set {
            if (newValue == nil) {
                UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.UserId)
            } else {
                UserDefaults.standard.set(newValue, forKey: Constants.UserDefaults.UserId)
            }
        }
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
        
        CKSession.removeSecure(key: Constants.UserDefaults.HKDataShare);
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
            if self?.userId != nil {
                self?.userId = nil
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
    /* func mapUser(_ data: [String: Any]) -> User? {
        
        let json = JSON(data)
        
        guard json["ID"] != JSON.null else {
            return nil
        }
        
        var userDict = json.dictionaryObject!
        userDict["userId"] = json["ID"].numberValue.stringValue
        
        return User(value: userDict)
    }*/
    
    func toMap() -> [String:Any] {
        guard let currentUser = SessionManager.shared.userId else {
            return [String:Any]()
        }
        
        return ["userId":currentUser]
    }
    
    func toThreadSafeMap() -> [String:Any] {
        guard let userId = SessionManager.shared.userId else {
            return [String:Any]()
        }
        
        return ["userId": userId]
    }
    
    // MARK: - User Defaults
    func checkFirstRun() {
        if self.getFirstRun() == nil { // app never run before
            
            if let hkResult = CKSession.getSecure(key: Constants.UserDefaults.HKDataShare),
                let hasUsedHealthKit = Bool(hkResult), hasUsedHealthKit {
                
                HealthKitManager.shared.disableHealthKit()
            }
            
            // if SessionManager.shared.userId == nil { //if we have no user...
                UIApplication.shared.applicationIconBadgeNumber = 0
                self.clearKeychainData() //clear the keychain
            // }
            
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
