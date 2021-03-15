//
//  PatientIDView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct PatientIDView: View {
    var userID = ""
    @ObservedObject var supplementalInfo = SupplementalUserInformation.shared
    
    init() {
        if let currentUser = CKStudyUser.shared.currentUser {
           self.userID = currentUser.uid
       }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Patient Name").font(.system(.headline)).foregroundColor(Color(.greyText()))
                Spacer()
            }
            HStack {
                Text("\(String(describing: supplementalInfo.retrieveSupplementalDictionary()!["firstName"])) \(String(describing: supplementalInfo.retrieveSupplementalDictionary()!["lastName"]))")
                    .font(.system(.body))
                    .foregroundColor(Color(.greyText()))
                Spacer()
            }
        }.frame(height: 100)
    }
}

struct PatientIDView_Previews: PreviewProvider {
    static var previews: some View {
        PatientIDView()
    }
}
