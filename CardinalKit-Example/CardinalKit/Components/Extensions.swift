//
//  Extensions.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/13/20.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

extension Color {
    static let greyText = Color(UIColor(netHex: 0x989998))

    static let lightWhite = Color(UIColor(netHex: 0xf7f8f7))
}
