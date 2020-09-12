//
//  PatientIDView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct PatientIDView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("PATIENT ID")
                .font(.system(.headline))
                .foregroundColor(.greyText)
            Text(CKStudyUser.shared.currentUser?.uid ?? "")
                .font(.system(.body))
                .foregroundColor(.greyText)
        }
        .padding(.vertical, 30)
    }
}

struct PatientIDView_Previews: PreviewProvider {
    static var previews: some View {
        PatientIDView()
    }
}
