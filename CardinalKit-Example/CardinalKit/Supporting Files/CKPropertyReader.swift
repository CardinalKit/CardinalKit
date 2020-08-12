//
//  CKPropertyReader.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/1/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

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
        let hex = self.read(query: query)
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
