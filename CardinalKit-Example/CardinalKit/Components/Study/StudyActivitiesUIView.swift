//
//  StudyActivitiesUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import ResearchKit

struct StudyActivitiesUIView: View {
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    var date = ""
    var activities: [StudyItem] = []
    
    init(color: Color) {
        self.color = color
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d, YYYY"
        
        self.date = formatter.string(from: date)
        
        let studyTableItems = StudyTableItem.allValues
        for study in studyTableItems {
            self.activities.append(StudyItem(study: study))
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
                Section(header: Text("Current Activities")) {
                    
                    ForEach(0 ..< self.activities.count) {
                        StudyActivityListItemView(icon: self.activities[$0].image, title: self.activities[$0].title, description: self.activities[$0].description, tasks: self.activities[$0].task)
                    }
                    
                }.listRowBackground(Color.white)
            }.listStyle(GroupedListStyle())
        }
    }
}

struct StudyItem: Identifiable {
    var id = UUID()
    let image: UIImage
    var title = ""
    var description = ""
    let task: ORKOrderedTask
    
    init(study: StudyTableItem) {
        self.image = study.image ?? UIImage(systemName: "questionmark.square")!
        self.title = study.title
        self.description = study.subtitle
        self.task = study.task
    }
}
