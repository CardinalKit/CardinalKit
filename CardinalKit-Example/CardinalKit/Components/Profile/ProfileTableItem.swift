//
//  ProfileTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation

enum ProfileTableItem: Int {
    
    case changePasscode, help, contactEmail, contactPhone, withdraw
    
    static func profileItem(forSection section: Int, row: Int) -> ProfileTableItem {
        switch section {
        case 0:
            if row == 0 {
                return .changePasscode
            }
            return .help
        case 1:
            if row == 0 {
                return .contactEmail
            }
            return .contactPhone
        default:
            return .withdraw
        }
    }
    
}
