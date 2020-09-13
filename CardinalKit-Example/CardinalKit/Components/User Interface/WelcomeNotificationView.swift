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
    let color: Color
    let date: String
    let activities: [StudyItem]
    @State var currTestIndex = 0
    
    init(color: Color) {
        self.color = color
        self.date = DateFormatter.mediumDate.string(from: Date())
        self.activities = StudyTableItem.allValues.map { StudyItem(study: $0) }
    }
    
    var body: some View {
        List(data.notifications) { notification in
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    HStack {
                        Text(notification.testName)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .heavy, design: .default))
                        Text(notification.text).foregroundColor(.white)
                    }
                    if notification.action {
                        Button(action: {
                            self.showingPopup = true
                        }) {
                            Text("  Take Test  ").foregroundColor(.black)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .alert(isPresented: self.$showingPopup) {
                            Alert(title: Text("Are you sure you want to take the test?"), message: Text("You may only take the test if you are in an adequate mental state"), primaryButton: .default(Text("Take Test"), action: {
                                self.currTestIndex = self.data.getTestIndex(testName: notification.testName)
                                self.showingTestDetail = true
                            }), secondaryButton: .cancel())
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(self.color)
            .cornerRadius(15)
            .shadow(radius: 5)
            .blur(radius: self.showingPopup ? 4 : 0)
        }
        .onAppear{ UITableView.appearance().separatorStyle = .none }
        .onDisappear{ UITableView.appearance().separatorStyle = .singleLine }
        .navigationBarItems(trailing: Text(date).foregroundColor(color))
        .sheet(isPresented: $showingTestDetail) {
            TaskVC(tasks: self.activities[self.currTestIndex].task)
        }
    }
}

struct WelcomeNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeNotificationView(color: .gray).environmentObject(NotificationsAndResults())
    }
}
