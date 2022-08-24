//
//  MainUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct MainUIView: View {
    @ObservedObject var presenter = MainPresenter()
    
    let color: Color
    let config = CKConfig.shared
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
    }
    
    var body: some View {
        TabView {
            TasksUIView(color: self.color).tabItem {
                Image("tab_tasks").renderingMode(.template)
                Text("Tasks")
            }
            
            if presenter.useCarekit && presenter.carekitLoaded {
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
    }
}

struct MainUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainUIView()
    }
}
