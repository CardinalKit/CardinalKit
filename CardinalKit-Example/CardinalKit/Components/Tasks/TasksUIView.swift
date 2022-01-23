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
    
    @State var useCloudSurveys = false
    
    @State var listItems = [CloudTaskItem]()
    @State var listItemsPerHeader = [String:[CloudTaskItem]]()
    @State var listItemsSections = [String]()
    
    let localListItems = LocalTaskItem.allValues
    var localListItemsPerHeader = [String:[LocalTaskItem]]()
    var localListItemsSections = [String]()
    
    init(color: Color) {
        self.color = color
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        date = formatter.string(from: Date())
        
        if localListItemsPerHeader.count <= 0 { // init
            for item in localListItems {
                if localListItemsPerHeader[item.section] == nil {
                    localListItemsPerHeader[item.section] = [LocalTaskItem]()
                    localListItemsSections.append(item.section)
                }
                
                localListItemsPerHeader[item.section]?.append(item)
            }
        }
    }
    
    func getRemoteItems(){
        CKResearchSurveysManager.shared.getTaskItems(onCompletion: {
            (results) in
            
            if let results = results as? [CloudTaskItem]{
                listItems = results
                var headerCopy = listItemsPerHeader
                var sectionsCopy = listItemsSections
                if listItemsPerHeader.count <= 0 { // init
                    for item in results {
                        if headerCopy[item.section] == nil {
                            headerCopy[item.section] = [CloudTaskItem]()
                            sectionsCopy.append(item.section)
                        }
                        if(((headerCopy[item.section]?.contains(item)) ?? false) == false){
                            headerCopy[item.section]?.append(item)
                        }
                    }
                }
                listItemsPerHeader=headerCopy
                listItemsSections=sectionsCopy
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
            
            if (useCloudSurveys){
                List {
                    ForEach(listItemsSections, id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(listItemsPerHeader[key]!, id: \.self) { item in
                                CloudTaskListItemView(item: item)
                            }
                        }.listRowBackground(Color.white)
                    }
                }.listStyle(GroupedListStyle())
            } else {
                List {
                    ForEach(localListItemsSections, id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(localListItemsPerHeader[key]!, id: \.self) { item in
                                LocalTaskListItemView(item: item)
                            }
                        }.listRowBackground(Color.white)
                    }
                }.listStyle(GroupedListStyle())
            }
        }
        .onAppear(perform: {
            self.useCloudSurveys = config.readBool(query: "Use Cloud Surveys")
            
            if(self.useCloudSurveys){
                getRemoteItems()
            }
        })
    }
}

struct TasksUIView_Previews: PreviewProvider {
    static var previews: some View {
        TasksUIView(color: Color.red)
    }
}
