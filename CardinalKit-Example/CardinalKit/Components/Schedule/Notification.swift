//
//  Notification.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

struct Notification: Hashable, Codable, Identifiable {
    
    var id: Int
    
    var title: String
    var body: String

    var hour: Int
}
