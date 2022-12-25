//
//  LocalTaskListItemView.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ResearchKit
import SwiftUI

struct LocalTaskListItemView: View {
    let item: LocalTaskItem

    @State var showingDetail = false
    
    var body: some View {
        HStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .accessibilityLabel(Text("Task Logo"))
            }
            VStack(alignment: .leading) {
                Text(item.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(item.subtitle).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }
        .frame(height: 65)
        .contentShape(
            Rectangle()
        )
        .gesture(
            TapGesture().onEnded {
                self.showingDetail.toggle()
            }
        )
        .sheet(
            isPresented: $showingDetail,
            onDismiss: {},
            content: {
                item.action
            }
        )
    }

    init(item: LocalTaskItem) {
        self.item = item
    }
}

struct LocalTaskListItemView_Previews: PreviewProvider {
    static var previews: some View {
        LocalTaskListItemView(item: .sampleCoreMotionAppleWatch)
    }
}
