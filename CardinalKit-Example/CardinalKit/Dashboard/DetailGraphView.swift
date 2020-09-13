//
//  DetailGraphView.swift
//  TrialX
//
//  Created by Lucas Wang on 2020-09-13.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct DetailGraphView: View {
    let date = DateFormatter.mediumDate.string(from: Date())
    let result: Result
    let color: Color

    var body: some View {
        VStack {
            Text(result.testName).font(Font.title.weight(.heavy))
            Text("Shown in order of oldest (left) to most recent (right).")
            HStack {
                ForEach(result.scores, id: \.self) { score in
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(self.color)
                            .frame(width: 20, height: CGFloat(score * 40))
                        Text(String(score))
                    }
                }
            }
            Spacer()
        }
        .navigationBarItems(trailing: Text(date).foregroundColor(color))
    }
}

//struct DetailGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailGraphView()
//    }
//}
