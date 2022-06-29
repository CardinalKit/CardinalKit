//
//  Libraries.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 29/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

class Libraries {
    
    public static var shared = Libraries()
    
    public var authlibrary:AuthLibrary
    public var networkingLibrary:NetworkingLibrary
    
    init(){
        self.authlibrary = FirebaseAuth()
        self.networkingLibrary = FirebaseStorage()
    }
}
