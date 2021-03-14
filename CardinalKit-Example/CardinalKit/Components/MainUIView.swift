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
            
//            DevicesView().tabItem {
//                Image(systemName: "rectangle.connected.to.line.below").renderingMode(.template)
//                Text("My Devices")
//            }
            
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
            CKStudyUser.shared.save()
            
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let atBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: startOfDay)!

            let dailyAtBreakfast = OCKScheduleElement(start: atBreakfast, end: nil, interval: DateComponents(day: 1))

            let schedule = OCKSchedule(composing: [dailyAtBreakfast])

            var bpTask = OCKTask(id: "bloodpressure", title: "Test Blood Pressure", carePlanUUID: nil, schedule: schedule)
            // task.instructions = "Test Blood Pressure"

            /*
             Drug + Diary Sample.
             Adapted from the Doxylamine and Nausea demo.
             */
            let thisMorning = Calendar.current.startOfDay(for: Date())
            let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: thisMorning)!
            let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo)!
            let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo)!
            
            // the schedule time determines the task checklist value?
            let drugSchedule = OCKSchedule(composing: [
                OCKScheduleElement(start: beforeBreakfast, end: nil,
                                   interval: DateComponents(day: 1)),
                OCKScheduleElement(start: afterLunch, end: nil,
                                   interval: DateComponents(day: 1))
            ])

            var drugTask = OCKTask(id: "drug", title: "Take Your Drug 💊",
                                     carePlanUUID: nil, schedule: drugSchedule)
            drugTask.instructions = "Tap the button below when you take your drug."

            let diarySchedule = OCKSchedule(composing: [
                OCKScheduleElement(start: beforeBreakfast, end: nil, interval: DateComponents(day: 1),
                                   text: "Anytime throughout the day", targetValues: [], duration: .allDay)
                ])

            var diaryTask = OCKTask(id: "diary", title: "Daily Diary",
                                 carePlanUUID: nil, schedule: diarySchedule)
            diaryTask.impactsAdherence = false
            diaryTask.instructions = "Tap the button below anytime you ate an apple 🍎."
            /* ---- */

            let store = OCKStore(name: "CKCareKitStore")
            store.addTasks([bpTask, diaryTask, drugTask], callbackQueue: DispatchQueue.main, completion: {result in
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
