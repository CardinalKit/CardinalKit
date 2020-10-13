//
//  ReportView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct ReportView: View {
    let color: Color
    var email = ""
    
    init(color: Color, email: String) {
        self.color = color
        self.email = email
    }
    
    var body: some View {
        HStack {
            Text("Report a Problem")
            Spacer()
            Text(self.email).foregroundColor(self.color)
        }
        .frame(height: 60)
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded({
            EmailHelper.shared.sendEmail(subject: "App Support Request", body: "Enter your support request here.", to: self.email)
        }))
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(color: Color.red, email: "support@cardinalkit.org")
    }
}
