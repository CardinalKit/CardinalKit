//
//  MainUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct MainUIView: View {
    let color: Color
    let config = CKConfig.shared
    
    @State var useCareKit = false
    @State var carekitLoaded = false

    var body: some View {
        TabView {
            TasksUIView(color: self.color).tabItem {
                Image("tab_tasks")
                    .renderingMode(.template)
                    .accessibilityLabel(Text("Tasks"))
                Text("Tasks")
            }
            
            if useCareKit && carekitLoaded {
                ScheduleViewControllerRepresentable()
                    .ignoresSafeArea(edges: .all)
                    .tabItem {
                        Image("tab_schedule")
                            .renderingMode(.template)
                            .accessibilityLabel(Text("Schedule"))
                        Text("Schedule")
                    }
                
                CareTeamViewControllerRepresentable()
                    .ignoresSafeArea(edges: .all)
                    .tabItem {
                        Image("tab_care")
                            .renderingMode(.template)
                            .accessibilityLabel(Text("Contact"))
                        Text("Contact")
                    }
            }

            ProfileUIView(color: self.color).tabItem {
                Image("tab_profile")
                    .renderingMode(.template)
                    .accessibilityLabel(Text("Profile"))
                Text("Profile")
            }
        }
        .accentColor(self.color)
        .onAppear(perform: {
            self.useCareKit = config.readBool(query: "Use CareKit") ?? false
            
            let lastUpdateDate = UserDefaults.standard.object(forKey: Constants.prefCareKitCoreDataInitDate) as? Date
            CKCareKitManager.shared.coreDataStore.populateSampleData(lastUpdateDate: lastUpdateDate) { () in
                self.carekitLoaded = true
            }
        })
    }

    init() {
        self.color = Color(config.readColor(query: "Primary Color") ?? UIColor.primaryColor())
    }
}

struct MainUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainUIView()
    }
}
