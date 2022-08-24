//
//  User.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 28/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

struct User {
    var email:String?
    var uid:String
    
    init(uid:String,email:String?) {
        self.uid = uid
        self.email = email
    }
    
    // TODO: Add Validators for a valid Email
}
