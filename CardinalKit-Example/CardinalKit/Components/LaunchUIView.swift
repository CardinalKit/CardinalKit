//
//  OnboardingUIView.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import UIKit
import ResearchKit
import CardinalKit
import Firebase

struct LaunchUIView: View {
    
    @State var showingStudyTasks = false
    
    init() {

    }

    var body: some View {
        VStack(spacing: 10) {
            if showingStudyTasks {
                StudiesUI()
            } else {
                OnboardingUIView() {
                    //on complete
                    if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
                       self.showingStudyTasks = completed as! Bool
                    }
                }
            }
        }.onAppear(perform: {
            if let completed = UserDefaults.standard.object(forKey: "didCompleteOnboarding") {
               self.showingStudyTasks = completed as! Bool
            }
        })
        
    }
}

struct LaunchUIView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchUIView()
    }
}
