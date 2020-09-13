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
    let color: Color
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        List(data.notifications) { notification in
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    Text(notification.text)
                    if notification.action {
                        Button(action: {
                        
                        }) {
                            Text("Take Test")
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(self.color)
            .cornerRadius(15)
            .shadow(radius: 15)
        }
        .onAppear{ UITableView.appearance().separatorStyle = .none }
        .onDisappear{ UITableView.appearance().separatorStyle = .singleLine }
    }
}

struct WelcomeNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeNotificationView(color: .gray).environmentObject(NotificationsAndResults())
    }
}
