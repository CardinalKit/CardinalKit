//
//  LocalTaskListItemView.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 10/27/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import ResearchKit

struct TaskItemView: View {
    @ObservedObject var presenter:TaskItemPresenter
    

    @State var showingDetail = false
    
    init(item: TaskItem) {
        self.presenter = TaskItemPresenter(item:item)
    }
    
    var body: some View {
        HStack {
            Image(uiImage: presenter.item.getImage()).resizable().frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(presenter.item.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(presenter.item.subtitle).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
        }
        .frame(height: 65)
        .contentShape(Rectangle()).gesture(TapGesture().onEnded({
            presenter.showDetail.toggle()
        }))
        .sheet(isPresented: $presenter.showDetail, onDismiss: {}, content: {
            presenter.item.View()
        })
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        TaskItemView(item: TaskItem(order: "1", title: "Title", subtitle: "Subtitle", image: "Example", section: "Section1", taskType: .custom, tasks: TaskSamples.sampleCoffeeTask))
    }
}
