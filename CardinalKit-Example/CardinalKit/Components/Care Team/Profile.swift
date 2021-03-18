//
//  Profile.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 2/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

struct Profile: Hashable, Codable, Identifiable {
    
    var id: Int
    
    var name: String
    var bio: String
    var location: String
    
    var email: String
    var mobilephone: String
    var officephone: String
    var fax: String
    
    var address_line1: String
    var address_line2: String
    var address_line3: String

    private var imageName: String
    var image: Image {
        Image(imageName)
    }
}
