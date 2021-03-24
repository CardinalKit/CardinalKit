//
//  ProfileView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import HealthKit
import Firebase
import EFStorageCore
import EFStorageKeychainAccess

extension HKBiologicalSex: CustomStringConvertible {
    public var description: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .notSet: return "Unknown"
        case .other: return "Other"
        @unknown default:
            return "Other/Unknown"
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var config: CKPropertyReader
    let color: Color

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(CKStudyUser.shared.currentUser?.displayName
                                ?? CKStudyUser.shared.currentUser?.uid
                                ?? "Unknown")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Sex Assigned at Birth")
                        Spacer()
                        Text(CKStudyUser.shared.sex.description)
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Date of Birth")
                        Spacer()
                        Text(CKStudyUser.shared.dateOfBirth.flatMap {
                            DateComponentsFormatter
                                .localizedString(from: $0, unitsStyle: .short)
                        } ?? "Unknown")
                        .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Education")
                        Spacer()
                        Text(CKStudyUser.shared.education ?? "Unknown")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Sex")
                        Spacer()
                        Text(CKStudyUser.shared.handedness ?? "Unknown")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Clinical Information")) {
                    HStack {
                        ConsentDocumentButton(title: "Consent Document (Signed)")
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                    HStack {
                        Button("EHR Access Permission") {
                            #warning("TODO")
                        }
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }

//                Section {
//                    HelpView(site: config.read(query: "Website"))
//                    SupportView(color: color, phone: config.read(query: "Phone"))
//                    ReportView(color: color, email: config.read(query: "Email"))
                //                    ChangePasscodeView()
//                }

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
            .environmentObject(CKConfig.shared)
    }
}
