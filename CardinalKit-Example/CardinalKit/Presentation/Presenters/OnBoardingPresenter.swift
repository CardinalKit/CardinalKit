//
//  OnBoardingPresenter.swift
//  CardinalKit_Example
//
//  Created by Esteban Ramos on 24/06/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation

struct OnboardingElement {
    let logo: String
    let title: String
    let description: String
}

struct OnBoardingViewModel{
    var studyLogo:String
    var studyTitle:String
    var onBoardingElements:[OnboardingElement]
    var teamName:String
    
    init(){
        let config = CKPropertyReader(file: "CKConfiguration")
        studyLogo = "SBDLogoGrey"
        studyTitle = config.read(query: "Study Title")
        teamName = config.read(query: "Team Name")
        onBoardingElements = []
        let onboardingData = config.readAny(query: "Onboarding") as! [[String:String]]
        for data in onboardingData {
            onBoardingElements.append(OnboardingElement(logo: data["Logo"]!, title: data["Title"]!, description: data["Description"]!))
        }
    }
}

class OnBoardingPresenter: ObservableObject {
    @Published var viewModel = OnBoardingViewModel()
    @Published var showNewUserSteps:Bool = false
    @Published var showExistinUserSteps:Bool = false
}
