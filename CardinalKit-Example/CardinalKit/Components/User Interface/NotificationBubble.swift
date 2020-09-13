//
//  NotificationBubble.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-12.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct NotificationBubble: View {
    @EnvironmentObject var data: NotificationsAndResults
    @Binding var showingPopup: Bool
    @Binding var showingTestDetail: Bool
    @Binding var currTestIndex: Int
    let notification: Notification
    let backGroundColor: Color
    let textColor: Color
    
    var body: some View {
        HStack {
                Spacer()
                VStack(spacing: 10) {
                    VStack {
                        Text(notification.testName)
                            .foregroundColor(textColor)
                            .font(.system(size: 20, weight: .heavy, design: .default))
                        Text(notification.text).foregroundColor(textColor)
                    }
                    if notification.action {
                        Button(action: {
                            self.showingPopup = true
                        }) {
                            Text("Take Test").foregroundColor(.black)
                        }
                        .padding(1)
                        .background(Color.white)
                        .cornerRadius(10)
                        .alert(isPresented: self.$showingPopup) {
                            Alert(title: Text("Are you sure you want to take the test?"), message: Text("You may only take the test if you are in an adequate mental state"), primaryButton: .default(Text("Take Test"), action: {
                                self.currTestIndex = self.data.getTestIndex(testName: self.notification.testName)
                                self.showingTestDetail = true
                            }), secondaryButton: .cancel())
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(self.backGroundColor)
            .cornerRadius(15)
            .shadow(radius: 5)
            .blur(radius: self.showingPopup ? 4 : 0)
    }
}

//struct NotificationBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationBubble()
//    }
//}
