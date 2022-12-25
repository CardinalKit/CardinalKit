//
//  Extensions+UIColor.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 10/12/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import UIKit

extension UIColor {
    /// Returns the UIColor used for 'gray' text
    class func grayText() -> UIColor {
        UIColor(netHex: 0x989998)
    }

    /// Returns the UIColor for 'light white'
    class func lightWhite() -> UIColor {
        UIColor(netHex: 0xf7f8f7)
    }

    class func primaryColor() -> UIColor {
        UIColor(red: 1.00, green: 0.22, blue: 0.38, alpha: 1.00)
    }
}
