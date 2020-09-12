//
//  ProfileView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var config: CKPropertyReader
    let color: Color

    var body: some View {
        NavigationView {
            List {
                Section {
                    PatientIDView()
                    ChangePasscodeView()
                }

                Section {
                    ConsentDocumentView()
                }

                Section {
                    HelpView(site: config.read(query: "Website"))
                    SupportView(color: color, phone: config.read(query: "Phone"))
                    ReportView(color: color, email: config.read(query: "Email"))
                }

                Section(footer: footer) {
                    WithdrawView()
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile")
        }
    }

    var footer: some View {
        Text(config.read(query: "Copyright"))
            .padding(.top, 16)
            .frame(maxWidth: .infinity)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(color: .accentColor)
    }
}
