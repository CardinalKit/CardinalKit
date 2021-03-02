//
//  MainUIView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI
import CareKit
import CareKitStore

struct MainUIView: View {
    
    let color: Color
    let config = CKConfig.shared
    
    @State var useCareKit = false
    
    init() {
        self.color = Color(config.readColor(query: "Primary Color"))
    }
    
    var body: some View {
        TabView {
            TasksUIView(color: self.color).tabItem {
                Image("tab_tasks").renderingMode(.template)
                Text("Tasks")
            }
            
            if useCareKit {
                ScheduleViewControllerRepresentable().tabItem {
                    Image("tab_schedule").renderingMode(.template)
                    Text("Schedule")
                }
                
                CareTeamViewControllerRepresentable().tabItem {
                    Image("tab_care").renderingMode(.template)
                    Text("Contact")
                }
            }
            
            DevicesView().tabItem {
                Image(systemName: "rectangle.connected.to.line.below").renderingMode(.template)
                Text("My Devices")
            }
            
            //            AboutUsView(dotColor: self.color).tabItem {
            //                Image(systemName: "book").renderingMode(.template)
            //                Text("About")
            //            }
            
            ProfileUIView(color: self.color).tabItem {
                Image("tab_profile").renderingMode(.template)
                Text("Profile")
            }
            
        }
        .accentColor(self.color)
        .onAppear(perform: {
            self.useCareKit = config.readBool(query: "Use CareKit")
            
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let atBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!
            
            let dailyAtBreakfast = OCKScheduleElement(start: atBreakfast, end: nil, interval: DateComponents(day: 1))
            
            let schedule = OCKSchedule(composing: [dailyAtBreakfast])
            
            var task = OCKTask(id: "bloodpressure", title: "Test Blood Pressure", carePlanUUID: nil, schedule: schedule)
            
            task.instructions = "Test Blood Pressure"
            
            let store = OCKStore(name: "CKCareKitStore")
            store.addTasks([task], callbackQueue: DispatchQueue.main, completion: {result in
                switch result {
                case .failure(let error) :
                    print(error.localizedDescription)
                case .success( _) :
                    print("Success!")
                }
                
            })
        })
    }
}

struct MainUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainUIView()
    }
}
