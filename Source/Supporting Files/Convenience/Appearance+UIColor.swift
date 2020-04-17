//
//  Appearance+UIColor.swift
//  CS342 Library
//
//  Created by Santiago Gutierrez on 9/1/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    
    class var victoria: UIColor {
        return UIColor(netHex: 0x52489C)
    }
    
    class var sanMarino: UIColor {
        return UIColor(netHex: 0x4262B8)
    }
    
    class var fountainBlue: UIColor {
        return UIColor(netHex: 0x59C3C3)
    }
    
    class var lilyWhite: UIColor {
        return UIColor(netHex: 0xEBEBEB)
    }
    
    class var altoGrey: UIColor {
        return UIColor(netHex: 0xDBDBDB)
    }
    
    class var radicalRed: UIColor {
        return UIColor(netHex: 0xFF3554)
    }
    
    class func greyishColor() -> UIColor {
        return UIColor(netHex: 0x4A4A4A)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
        self.withAlphaComponent(alpha)
    }
}
