//
//  ActivitiesView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/13/20.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI
import ResearchKit

struct ActivitiesView: View {
    let color: Color
    let date = DateFormatter.mediumDate.string(from: Date())
    let activities = StudyTableItem.allCases.map { StudyItem(study: $0) }
    @EnvironmentObject var config: CKPropertyReader

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Testing activities")) {
                    ForEach(activities) { activity in
                        ActivityView(
                            icon: activity.image,
                            title: activity.title,
                            description: activity.description,
                            tasks: activity.task
                        )
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(config.read(query: "Study Title"))
            .navigationBarItems(trailing: Text(date).foregroundColor(color))
        }
    }
}

struct ActivityView: View {
    let icon: UIImage
    var title: String
    var description: String
    let tasks: ORKOrderedTask
    @State var showingDetail = false

    
    var body: some View {
        Button(action: {
            self.showingDetail.toggle()
        }, label: {
            HStack(spacing: 8) {
                Image(uiImage: self.icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)

                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(Font.headline.weight(.semibold))
                    Text(self.description)
                        .font(Font.subheadline.weight(.light))
                        .foregroundColor(.primary)
                }
            }
        })
        .padding(.vertical)
        .sheet(isPresented: $showingDetail) {
            TaskVC(tasks: self.tasks)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(color: .accentColor)
    }
}
