//
//  LocalTaskListItemView.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import ResearchKit

struct LocalTaskListItemView: View {
    
    let item: LocalTaskItem

    @State var showingDetail = false
    
    init(item: LocalTaskItem) {
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

struct LocalTaskListItemView_Previews: PreviewProvider {
    static var previews: some View {
        LocalTaskListItemView(item: .sampleCoreMotionAppleWatch)
    }
}
