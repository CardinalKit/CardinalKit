//
//  StatisticsView.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-13.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var data: NotificationsAndResults
    let date = DateFormatter.mediumDate.string(from: Date())

    let color: Color

    var body: some View {
        PlainList {
            Section(header: Text("Here, you can review your scores and trends")) {
                ForEach(self.data.results) { result in
                    StatisticsBubble(result: result, backGroundColor: .white, textColor: self.color)
                    .padding(4)
                }
            }
        }
        .environmentObject(NotificationsAndResults())
        .navigationBarItems(trailing: Text(date).foregroundColor(color))
    }
}
