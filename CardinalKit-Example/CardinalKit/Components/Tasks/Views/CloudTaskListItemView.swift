//
//  TaskListItemView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit
import SwiftUI

struct CloudTaskListItemView: View {
    let item: CloudTaskItem
    @State var showingDetail = false
    
    var body: some View {
        HStack {
            if let image = item.image {
                Image(uiImage: image).resizable().frame(width: 32, height: 32)
            }
            VStack(alignment: .leading) {
                Text(item.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(item.subtitle).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }
        .frame(height: 65)
        .contentShape(Rectangle())
        .gesture(
            TapGesture().onEnded {
                self.showingDetail.toggle()
            }
        )
        .sheet(isPresented: $showingDetail, onDismiss: {}, content: {
            item.view()
        })
    }

    init(item: CloudTaskItem) {
        self.item = item
    }
}
