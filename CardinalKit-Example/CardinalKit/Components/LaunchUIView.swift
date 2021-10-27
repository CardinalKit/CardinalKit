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
    
    @State var didCompleteOnboarding = false
    
    init() {
        
    }

    var body: some View {
        VStack(spacing: 10) {
            if didCompleteOnboarding && (CKStudyUser.shared.currentUser != nil){
                MainUIView()
            } else {
                OnboardingUIView() {
                    //on complete
                    if let completed = UserDefaults.standard.object(forKey: Constants.onboardingDidComplete) as? Bool {
                       self.didCompleteOnboarding = completed
                    }
                }
            }
        }.onAppear(perform: {
            if let completed = UserDefaults.standard.object(forKey: Constants.onboardingDidComplete) as? Bool {
               self.didCompleteOnboarding = completed
            }
        }).onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(Constants.onboardingDidComplete))) { notification in
            if let newValue = notification.object as? Bool {
                self.didCompleteOnboarding = newValue
            } else if let completed = UserDefaults.standard.object(forKey: Constants.onboardingDidComplete) as? Bool {
               self.didCompleteOnboarding = completed
            }
        }
        
    }
}

struct LaunchUIView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchUIView()
    }
}
