//
//  CKPropertyReader.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public class CKPropertyReader {
    
    var data: [String: AnyObject] = [:]
    
    init(file: String) {
        
        // read input plist file
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        let plistPath: String? = Bundle.main.path(forResource: file, ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        
        // convert plist file into dictionary
        do {
            self.data = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]

        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
    }
    
    // read from stored value
    func read(query: String) -> String {
        return data[query] as! String
    }
    
    func readBool(query: String) -> Bool {
        return data[query] as! Bool
    }
    
    func readAny(query: String) -> AnyObject {
        return data[query]!
    }
    
    // read from stored dictionary
    func readDict(query: String) -> [String:String] {
        return data[query] as! [String:String]
    }

    subscript(query: String) -> [String: AnyObject] {
        return data[query] as! [String: AnyObject]
    }

    // read from stored dictionary
    func readArray(query: String) -> [String] {
        return data[query] as! [String]
    }
    
    // read color from stored dictionary
    func readColor(query: String) -> UIColor {
        let hex = self.read(query: query)
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(netHex: Int(rgbValue))
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

extension Color {
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.rgba.red),
                  green: Double(uiColor.rgba.green),
                  blue: Double(uiColor.rgba.blue),
                  opacity: Double(uiColor.rgba.alpha))
    }
}
