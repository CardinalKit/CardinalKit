//
//  CKCareKitManager+Sample.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/21/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import CareKit
import Contacts
import UIKit
import CardinalKit
import CareKitStore

internal extension OCKStore {    
    func createContacts() {
        let config = CKPropertyReader(file: "CKConfiguration")
        let contactData = config.readAny(query: "Contacts") as! [[String:String]]
//        Have to put it into a list so we can reverse the list later
        var ockContactElements: [OCKContact] = []
        for data in contactData {
            let address = OCKPostalAddress()
            var thisContact = OCKContact(id: data["givenName"]! + data["familyName"]!, givenName: data["givenName"]!, familyName: data["familyName"]!, carePlanUUID: nil)
//            If you have an image named exactly givenNamefamilyName, in assets, it will be put on contact card
            thisContact.asset = data["givenName"]! + data["familyName"]!
            for (k, v) in data {
                k == "role" ? thisContact.role = v :
                k == "title" ? thisContact.title = v :
                k == "email" ? thisContact.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: v)] :
                k == "phone" ? thisContact.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: v)] :
                k == "test" ? thisContact.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: v)] :
                k == "street" ? address.street = v :
                k == "city" ? address.city = v :
                k == "state" ? address.state = v :
                k == "postalCode" ? address.postalCode = v :
                ()
            }
            if address != OCKPostalAddress() {
                thisContact.address = address
            }
            ockContactElements.append(thisContact)
        }
        addContacts(ockContactElements.reversed())
    }
}
