//
//  SupplementalUserInformation.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 3/14/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

class SupplementalUserInformation : ObservableObject {
    static let shared = SupplementalUserInformation()
    
    @Published var dictionary: [String : Any]? = UserDefaults.standard.object(forKey: "supplementalUserInfo") as? [String : Any]
    
    func setSupplementalDictionary(newDict: [String : Any]?) {
        dictionary = newDict
        UserDefaults.standard.set(newDict, forKey: "supplementalUserInfo")
    }
    
    func retrieveSupplementalDictionary() -> [String : Any]? {
        return dictionary
    }
}
