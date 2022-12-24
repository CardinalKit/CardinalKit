//
//  CKPropertyReader.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/1/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

public class CKPropertyReader {
    var data: [String: AnyObject] = [:]
    
    init(file: String) {
        // read input plist file
        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        guard let plistPath = Bundle.main.path(forResource: file, ofType: "plist"),
              let plistXML = FileManager.default.contents(atPath: plistPath) else {
            return
        }
        
        // convert plist file into dictionary
        do {
            let data = try PropertyListSerialization.propertyList(
                from: plistXML,
                options: .mutableContainersAndLeaves,
                format: &propertyListFormat
            )
            if let dataDict = data as? [String: AnyObject] {
                self.data = dataDict
            }
        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
    }

    // read from stored value
    func read(query: String) -> String? {
        return data[query] as? String
    }

    func readBool(query: String) -> Bool? {
        return data[query] as? Bool
    }

    func readAny(query: String) -> AnyObject? {
        return data[query]
    }

    // read from stored dictionary
    func readDict(query: String) -> [String: String]? {
        return data[query] as? [String: String]
    }

    subscript(query: String) -> [String: AnyObject]? {
        return data[query] as? [String: AnyObject]
    }

    // read from stored dictionary
    func readArray(query: String) -> [String]? {
        return data[query] as? [String]
    }

    // read color from stored dictionary
    func readColor(query: String) -> UIColor? {
        guard let hex = self.read(query: query) else {
            return nil
        }
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    // swiftlint:disable:next large_tuple
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
        self.init(
            red: Double(uiColor.rgba.red),
            green: Double(uiColor.rgba.green),
            blue: Double(uiColor.rgba.blue),
            opacity: Double(uiColor.rgba.alpha)
        )
    }
}
