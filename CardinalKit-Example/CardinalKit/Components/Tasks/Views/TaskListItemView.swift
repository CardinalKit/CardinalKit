//
//  TaskListItemView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import ResearchKit

struct TaskListItemView: View {
    
    let item: TaskItem

    @State var showingDetail = false
    
    init(item: TaskItem) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            if item.image != nil {
                Image(uiImage: item.image!).resizable().frame(width: 32, height: 32)
            }
            VStack(alignment: .leading) {
                Text(item.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(item.subtitle).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }
        .frame(height: 65)
        .contentShape(Rectangle()).gesture(TapGesture().onEnded({
            self.showingDetail.toggle()
        }))
        .sheet(isPresented: $showingDetail, onDismiss: {}, content: {
                item.action
        })
    }
}

struct TaskListItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListItemView(item: .sampleCoreMotionAppleWatch)
    }
}
