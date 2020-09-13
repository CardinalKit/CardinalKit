//
//  StatisticsBubble.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-13.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct StatisticsBubble: View {
    @EnvironmentObject var data: NotificationsAndResults
    let result: Result
    let backGroundColor: Color
    let textColor: Color
    
    var body: some View {
        ZStack {
            NavigationLink(destination: DetailGraphView(result: result, color: textColor)) {
                EmptyView()
            }
            HStack {
                Text(result.testName)
                    .foregroundColor(textColor)
                    .font(Font.title.weight(.heavy))
                    .padding(.vertical)
                    .padding(.leading)
                Spacer()
                HStack(spacing: 8) {
                    Text("\(String(format: "%.1f", data.getLastestScore(scores: result.scores)))")
                        .font(Font.largeTitle.monospacedDigit())
                    Image(systemName: "chevron.right.square.fill")
                        .accessibility(label: Text("Show all scores"))
                }
                .foregroundColor(backGroundColor)
                .padding()
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxHeight: .infinity)
                .background(textColor)

            }
        }
        .frame(maxWidth: .infinity)
        .background(self.backGroundColor)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

//struct StatisticsBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        StatisticsBubble()
//    }
//}
