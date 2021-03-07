//
//  DaysSinceSurgeryView.swift
//  CardinalKit_Example
//
//  Created by Kabir Jolly on 3/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct DaysSinceSurgeryView: View {
    let days: Int
    
    init(days: Int) {
        self.days = days
    }
    
    var body: some View {
        HStack {
            Text("Days since transplant surgery")
            Spacer()
            Text(String(self.days)).bold()
        }
        .frame(height: 60)
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded({
        }))
    }
}
