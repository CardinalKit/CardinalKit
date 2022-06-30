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

struct LaunchUIView: View {
    @ObservedObject var presenter = LaunchPresenter()

    var body: some View {
        VStack(spacing: 10) {
            if (presenter.didCompleteOnBoarding){
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
