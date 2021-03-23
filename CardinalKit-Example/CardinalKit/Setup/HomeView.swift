//
//  HomeView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/13/20.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var config: CKPropertyReader
    @EnvironmentObject var data: NotificationsAndResults
    var color: Color {
        return Color(config.readColor(query: "Primary Color"))
    }

    var body: some View {
        TabView {
            NavigationView {
                WelcomeNotificationView(color: color).navigationBarTitle("Home")
            }
            .tabItem {
                Image(systemName: "house")
                    .renderingMode(.template)
                Text("Home")
            }
            
            NavigationView {
                StatisticsView(color: color).navigationBarTitle("Statistics")
            }
            .tabItem {
                Image(systemName: "gauge")
                    .renderingMode(.template)
                Text("Statistics")
            }

//            ActivitiesView(color: color)
//                .tabItem {
//                    Image("tab_activities")
//                        .renderingMode(.template)
//                    Text("Testing Activities")
//                }

            ProfileView(color: color)
                .tabItem {
                    Image("tab_profile")
                        .renderingMode(.template)
                    Text("Profile")
                }
        }
        .accentColor(color)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
