//
//  StudyActivitiesUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import ResearchKit
import CardinalKit

struct TasksUIView: View {
    
    var date = ""
    
    let color: Color
    let config = CKConfig.shared
    
    @State var listItems = [TaskItem]()
    @State var listItemsPerHeader = [String:[TaskItem]]()
    @State var listItemsSections = [String]()
    
    init(color: Color) {
//        if let customDelegate = CKApp.instance.configure() {
//        
//        }
        
        
        self.color = color
//        getItems()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        date = formatter.string(from: Date())
//        self.date = "Joder asignele valor"
        //here get items from firebase
        
        
    }
    
    func getItems(){
        CKResearchSurveysManager.shared.getTaskItems(onCompletion: {
            (results) in
            
            if let results = results as? [TaskItem]{
                listItems = results
                if listItemsPerHeader.count <= 0 { // init
                    for item in results {
                        if listItemsPerHeader[item.section] == nil {
                            listItemsPerHeader[item.section] = [TaskItem]()
                            listItemsSections.append(item.section)
                        }

                        listItemsPerHeader[item.section]?.append(item)
                    }
                }
            }
        })
    }
    
    var body: some View {
        VStack {
            Text(config.read(query: "Study Title"))
                .font(.system(size: 25, weight:.bold))
                .foregroundColor(self.color)
                .padding(.top, 10)
            Text(config.read(query: "Team Name")).font(.system(size: 15, weight:.light))
            Text(date).font(.system(size: 18, weight: .regular)).padding()
            Text(String(listItems.count))
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
        .onAppear(perform: {
            getItems()
        })
    }
}

struct TasksUIView_Previews: PreviewProvider {
    static var previews: some View {
        TasksUIView(color: Color.red)
    }
}
