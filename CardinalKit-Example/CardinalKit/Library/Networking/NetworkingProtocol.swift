//
//  NetworkingProtocol.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 29/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

protocol NetworkingLibrary {
    func sendFile(url:URL, path:String)
    func checkIfFileExist(url:URL, path:String,onComplete:@escaping (Bool)->Void)
}
