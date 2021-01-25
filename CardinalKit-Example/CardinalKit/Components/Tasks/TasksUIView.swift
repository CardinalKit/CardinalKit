//
//  StudyActivitiesUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import ResearchKit

struct TasksUIView: View {
    
    var date = ""
    
    let color: Color
    let config = CKConfig.shared
    
    let listItems = TaskItem.allValues
    var listItemsPerHeader = [String:[TaskItem]]()
    var listItemsSections = [String]()
    
    init(color: Color) {
        self.color = color
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        self.date = formatter.string(from: Date())
        
        if listItemsPerHeader.count <= 0 { // init
            for item in listItems {
                if listItemsPerHeader[item.section] == nil {
                    listItemsPerHeader[item.section] = [TaskItem]()
                    listItemsSections.append(item.section)
                }
                
                listItemsPerHeader[item.section]?.append(item)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(config.read(query: "Study Title"))
                .font(.system(size: 25, weight:.bold))
                .foregroundColor(self.color)
                .padding(.top, 10)
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            Text(self.date).font(.system(size: 18, weight: .regular)).padding()
            List {
                ForEach(listItemsSections, id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(listItemsPerHeader[key]!, id: \.self) { item in
                            TaskListItemView(item: item)
                        }
                    }.listRowBackground(Color.white)
                }
            }.listStyle(GroupedListStyle())
        }
    }
}

struct TasksUIView_Previews: PreviewProvider {
    static var previews: some View {
        TasksUIView(color: Color.red)
    }
}
