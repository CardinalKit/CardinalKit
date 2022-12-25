//
//  OnboardingUIView.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Firebase
import ResearchKit
import SwiftUI
import UIKit

struct LaunchUIView: View {
    @AppStorage(Constants.onboardingDidComplete) var didCompleteOnboarding = false
    @ObservedObject var auth = CKStudyUser.shared

    var body: some View {
        VStack(spacing: 10) {
            if didCompleteOnboarding && (auth.currentUser != nil) {
                MainUIView()
            } else {
                OnboardingUIView()
            }
        }
    }
}

struct LaunchUIView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchUIView()
    }
}
