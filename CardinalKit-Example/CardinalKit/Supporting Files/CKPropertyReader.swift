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

public class CKPropertyReader: ObservableObject {
    
    private var data: [String: AnyObject] = [:]
    
    public init(file: String) {
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
    public func read(query: String) -> String {
        return data[query] as! String
    }
    
    public func readAny(query: String) -> AnyObject {
        return data[query]!
    }
    
    // read from stored dictionary
    public func readDict(query: String) -> [String:String] {
        return data[query] as! [String:String]
    }
    
    // read from stored dictionary
    public func readArray(query: String) -> [String] {
        return data[query] as! [String]
    }
    
    // read color from stored dictionary
    public func readUIColor(query: String) -> UIColor {
        let hex = read(query: query)
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        assert(cString.count == 6, "Invalid color string")

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(netHex: Int(rgbValue)) // or return any universal color, we can alter this a bit
    }

    public func readColor(query: String) -> Color {
        return Color(readUIColor(query: query))
    }
}
