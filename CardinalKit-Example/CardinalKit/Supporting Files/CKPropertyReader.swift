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
    
    func readAny(query: String) -> AnyObject {
        return data[query]!
    }
    
    // read from stored dictionary
    func readDict(query: String) -> [String:String] {
        return data[query] as! [String:String]
    }
    
    // read from stored dictionary
    func readArray(query: String) -> [String] {
        return data[query] as! [String]
    }
    
    // read color from stored dictionary
    func readColor(query: String) -> UIColor {
        let hex = read(query: query)
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            displayP3Red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgbValue & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
