//
//  WelcomeNotificationView.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct WelcomeNotificationView: View {
    @EnvironmentObject var data: NotificationsAndResults
    @EnvironmentObject var config: CKPropertyReader
    @State private var showingPopup = false
    @State private var showingTestDetail = false
    @State private var currTestIndex = 0
    let date = DateFormatter.mediumDate.string(from: Date())
    let activities = StudyTableItem.allCases.map { StudyItem(study: $0) }

    let color: Color

    var body: some View {
        PlainList {
            Section(header: Text("Avaliable Test(s)")) {
                ForEach(self.data.currNotifications) { notification in
                    NotificationBubble(
                        showingPopup: self.$showingPopup,
                        showingTestDetail: self.$showingTestDetail,
                        currTestIndex: self.$currTestIndex,
                        notification: notification,
                        backGroundColor: self.color,
                        textColor: .white
                    )
                    .padding(4)
                }
            }
            
            Section(header: Text("Upcoming Test(s) and Cautions")) {
                ForEach(self.data.upcomingNotifications) { notification in
                    NotificationBubble(
                        showingPopup: self.$showingPopup,
                        showingTestDetail: self.$showingTestDetail,
                        currTestIndex: self.$currTestIndex,
                        notification: notification,
                        backGroundColor: .white /*Color(UIColor.systemGroupedBackground)*/,
                        textColor: self.color
                    )
                    .padding(3)
                }
            }
        }
        .environmentObject(NotificationsAndResults())
        .navigationBarItems(trailing: Text(date).foregroundColor(color))
        .sheet(isPresented: $showingTestDetail) {
            TaskVC(tasks: self.activities[self.currTestIndex].task)
        }
    }
}

struct WelcomeNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeNotificationView(color: .gray)
            .environmentObject(NotificationsAndResults())
    }
}
