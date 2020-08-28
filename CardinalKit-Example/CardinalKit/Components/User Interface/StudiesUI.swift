//
//  StudiesUI.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct StudiesUI: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
    }
    
    var body: some View {
        TabView {
            ActivitiesView(color: self.color)
                .tabItem {
                    Image("tab_activities").renderingMode(.template)
                    Text("Activities")
            }

            ProfileView(color: self.color)
                .tabItem {
                    Image("tab_profile").renderingMode(.template)
                    Text("Profile")
                }
        }.accentColor(self.color)
    }
}

struct ActivitiesView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        VStack {
            Text(config.read(query: "Study Title")).font(.system(size: 25, weight:.bold)).foregroundColor(self.color)
            
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            Text("Aug. 26, 2020").font(.system(size: 18, weight: .regular)).padding()
            List {
                Section(header: Text("Current Activities")) {
                    
                        ActivityView().gesture(TapGesture().onEnded({
                            print("Activity!")
                        }))
                    
                }.listRowBackground(Color.white)
            }.listStyle(GroupedListStyle())
        }
    }
}

struct ActivityView: View {
    var body: some View {
        HStack {
            Image("SurveyIcon").resizable().frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text("Survey Title").font(.system(size: 18, weight: .semibold, design: .default))
                Text("Survey Description").font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }.frame(height: 65).contentShape(Rectangle())
    }
}

struct WithdrawView: View {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Withdraw from Study").foregroundColor(self.color)
            Spacer()
            Text("›").foregroundColor(self.color)
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            print("Withdraw!")
        }))
    }
}

struct ReportView: View {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Report a Problem")
            Spacer()
            Text("contact@domain.com").foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            print("Email!")
        }))
    }
}

struct SupportView: View {
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Support")
            Spacer()
            Text("(408) 123-4567").foregroundColor(self.color)
        }.frame(height: 60).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            print("Support!")
        }))
    }
}

struct HelpView: View {
    var body: some View {
        HStack {
            Text("Help")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            print("Help!")
        }))
    }
}

struct ChangePasscodeView: View {
    var body: some View {
        HStack {
            Text("Change Passcode")
            Spacer()
            Text("›")
        }.frame(height: 70).contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
            print("Passcode!")
        }))
    }
}

struct PatientIDView: View {
    var body: some View {
        VStack {
            Text("PATIENT ID").font(.system(.headline)).foregroundColor(Color(.greyText()))
            Text("[patient id]").font(.system(.body)).foregroundColor(Color(.greyText()))
        }.frame(height: 100)
    }
}

struct ProfileView: View {
    let color: Color
    
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
                    HelpView()
                }
                
                Section {
                    ReportView(color: self.color)
                    SupportView(color: self.color)
                }
                
                Section {
                    WithdrawView(color: self.color)
                }
                
                Section {
                    Text("Made at Stanford with ❤️")
                }
            }.listStyle(GroupedListStyle())
        }
    }
}


struct StudiesUI_Previews: PreviewProvider {
    static var previews: some View {
        StudiesUI()
    }
}

public extension UIColor {
    class func greyText() -> UIColor {
        return UIColor(netHex: 0x989998)
    }
    
    class func lightWhite() -> UIColor {
        return UIColor(netHex: 0xf7f8f7)
    }
}
