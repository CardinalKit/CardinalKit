//
//  CKConfig.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

class CKConfig : CKPropertyReader {
    
    static let shared = CKPropertyReader(file: "CKConfiguration")
    
}
