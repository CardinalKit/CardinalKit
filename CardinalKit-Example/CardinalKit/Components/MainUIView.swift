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
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
        
    }
    
    var body: some View {
        TabView {
            TasksUIView(color: self.color).tabItem {
                Image("tab_tasks").renderingMode(.template)
                Text("Tasks")
            }
            
            if useCareKit && carekitLoaded {
                ScheduleViewControllerRepresentable()
                    .ignoresSafeArea(edges: .all)
                    .tabItem {
                        Image("tab_schedule").renderingMode(.template)
                        Text("Schedule")
                }
                
                CareTeamViewControllerRepresentable()
                    .ignoresSafeArea(edges: .all)
                    .tabItem {
                        Image("tab_care").renderingMode(.template)
                        Text("Contact")
                }
            }

            ProfileUIView(color: self.color).tabItem {
                Image("tab_profile").renderingMode(.template)
                Text("Profile")
            }
        }
        .accentColor(self.color)
        .onAppear(perform: {
            self.useCareKit = config.readBool(query: "Use CareKit")
            
            let lastUpdateDate:Date? = UserDefaults.standard.object(forKey: Constants.prefCareKitCoreDataInitDate) as? Date
            CKCareKitManager.shared.coreDataStore.populateSampleData(lastUpdateDate:lastUpdateDate){() in
                self.carekitLoaded = true
            }
            
            
        })
    }
}

struct MainUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainUIView()
    }
}
