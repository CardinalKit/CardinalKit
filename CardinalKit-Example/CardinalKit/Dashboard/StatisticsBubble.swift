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
        HStack() {
            VStack {
                Text(result.testName)
                    .foregroundColor(textColor)
                    .font(Font.title.weight(.heavy))
                Text("Most recent score: \(String(data.getLastestScore(scores: result.scores)))")
            }
            NavigationLink(destination: DetailGraphView(result: result, color: textColor)) {
                Text("All scores").multilineTextAlignment(.center)
            }
            .frame(width: 70)
        }
        .padding(.vertical)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(self.backGroundColor)
        .cornerRadius(15)
        .shadow(color: Color(UIColor.placeholderText), radius: 5, x: 3, y: 3)
    }
}

//struct StatisticsBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        StatisticsBubble()
//    }
//}
