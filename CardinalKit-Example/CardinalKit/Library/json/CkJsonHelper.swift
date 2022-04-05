//
//  CkJsonHelper.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 25/03/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class CKJsonHelper{
    /**
     Parse a JSON Data object and convert to a dictionary.
    */
    public static func jsonDataAsDict(_ jsonData: Data) throws -> [String:Any]? {
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
    }
}
