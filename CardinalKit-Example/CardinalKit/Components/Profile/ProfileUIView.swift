//
//  ProfileUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct ProfileUIView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        VStack {
            Text("Profile").font(.system(size: 25, weight:.bold))
            List {
                Section {
                    PatientIDView()
                }.listRowBackground(Color.white)
                
                Section {
                    ChangePasscodeView()
                    HelpView(site: config.read(query: "Website"))
                }
                
                Section {
                    ReportView(color: self.color, email: config.read(query: "Email"))
                    SupportView(color: self.color, phone: config.read(query: "Phone"))
                    DocumentPreviewView()
                }
                
                Section {
                    WithdrawView(color: self.color)
                }
                
                Section {
                    Text(config.read(query: "Copyright"))
                }
            }.listStyle(GroupedListStyle())
        }
    }
}
