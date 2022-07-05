//
//  LaunchPresenter.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 24/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

class LaunchPresenter:ObservableObject{
    @Published var didCompleteOnBoarding:Bool
    
    init(){
        let authLibrary = Dependencies.container.resolve(AuthLibrary.self)!
        didCompleteOnBoarding = UserDefaults.standard.bool(forKey: Constants.onboardingDidComplete) && authLibrary.user != nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(onBoardingStateChange), name: .onBoardingStateChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserStateChange), name: .onUserStateChange, object: nil)
    }
    
    @objc func onBoardingStateChange(_ notification: Notification){
        if let newValue = notification.object as? Bool {
            didCompleteOnBoarding = newValue
        }
    }
    
    @objc func onUserStateChange(_ notification: Notification){
        if let newValue = notification.object as? Bool{
            if newValue {
                if UserDefaults.standard.bool(forKey: Constants.onboardingDidComplete) {
                    didCompleteOnBoarding = true
                }
            }
            else{
                if didCompleteOnBoarding {
                    didCompleteOnBoarding = false
                }
                UserDefaults.standard.set(false, forKey: Constants.onboardingDidComplete)
            }
        }
    }
}
