//
//  User.swift
//  Vasctrac
//
//  Created by Developer on 3/13/16.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    @objc dynamic var userId: String!
    @objc dynamic var eId: String!
    @objc fileprivate(set) dynamic var picture: Data? = nil // stored locally only
    @objc dynamic var informedConsent: Bool = false
    @objc dynamic var completedOnboarding: Bool = false
    
    @objc fileprivate(set) dynamic var lastDateStepsDataSent : Date? = nil // stored locally only
    
    //var messages : List<Message>? = nil
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    func dailyDataSent(withDate lastDate: Date) {
        let realm = try! Realm()
        try! realm.write {
            self.lastDateStepsDataSent = lastDate
        }
    }
    
    func profilePicture(_ picture: Data?) {
        let realm = try! Realm()
        try! realm.write {
            self.picture = picture
        }
    }
    
    func updateOnboarding(completed: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.completedOnboarding = completed
        }
    }
    
    func updateConsent(completed: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.informedConsent = completed
        }
    }

}
