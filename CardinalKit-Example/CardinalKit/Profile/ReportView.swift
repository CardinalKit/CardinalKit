//
//  ReportView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct ReportView: View {
    let color: Color
    let email: String

    var body: some View {
        HStack {
            Text("Report a Problem")
            Spacer()
            Text(email)
                .foregroundColor(color)
        }
        .padding(.vertical)
        .onTapGesture {
            EmailHelper.shared
                .sendEmail(subject: self.email,
                           body: "App Support Request",
                           to: "Enter your support request here.")
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(color: .accentColor, email: "")
    }
}
