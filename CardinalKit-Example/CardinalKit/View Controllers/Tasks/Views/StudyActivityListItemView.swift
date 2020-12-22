//
//  StudyActivityListItemView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import ResearchKit

struct StudyActivityListItemView: View {
    let icon: UIImage
    var title = ""
    var description = ""
    let tasks: ORKOrderedTask
    @State var showingDetail = false
    
    init(icon: UIImage, title: String, description: String, tasks: ORKOrderedTask) {
        self.icon = icon
        self.title = title
        self.description = description
        self.tasks = tasks
    }
    
    var body: some View {
        HStack {
            Image(uiImage: self.icon).resizable().frame(width: 32, height: 32)
            VStack(alignment: .leading) {
                Text(self.title).font(.system(size: 18, weight: .semibold, design: .default))
                Text(self.description).font(.system(size: 14, weight: .light, design: .default))
            }
            Spacer()
            }.frame(height: 65).contentShape(Rectangle()).gesture(TapGesture().onEnded({
                self.showingDetail.toggle()
            })).sheet(isPresented: $showingDetail, onDismiss: {
                
            }, content: {
                CKTaskViewController(tasks: self.tasks)
            })
    }
}

struct StudyActivityListItemView_Previews: PreviewProvider {
    static var previews: some View {
        StudyActivityListItemView(icon: UIImage(named: "CoffeeIcon")!, title: "Preview Item", description: "This item is just for preview.", tasks: StudyTasks.coffeeTask)
    }
}
