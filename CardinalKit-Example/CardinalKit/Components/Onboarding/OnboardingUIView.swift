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

struct OnboardingElement {
    let logo: String
    let title: String
    let description: String
}

struct OnboardingUIView: View {
    var onboardingElements: [OnboardingElement] = []
    let color: Color
    let config = CKPropertyReader(file: "CKConfiguration")
    @State var showingOnboard = false
    @State var showingLogin = false
    
    var onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.color = Color(config.readColor(query: "Primary Color") ?? UIColor.primaryColor())
        self.onComplete = onComplete

        if let onboardingData = config.readAny(query: "Onboarding") as? [[String: String]] {
            for data in onboardingData {
                guard let logo = data["Logo"],
                      let title = data["Title"],
                      let description = data["Description"] else {
                    continue
                }

                let element = OnboardingElement(
                    logo: logo,
                    title: title,
                    description: description
                )

                self.onboardingElements.append(element)
            }
        }
    }

    // swiftlint:disable closure_body_length
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image("SBDLogoGrey")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.paddingHorizontalMain * 4)
                .padding(.trailing, Metrics.paddingHorizontalMain * 4)
                .accessibilityLabel(Text("Logo"))
            
            Spacer(minLength: 2)
            
            Text(config.read(query: "Study Title") ?? "CardinalKit")
                .foregroundColor(self.color)
                .multilineTextAlignment(.center)
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)
            
            Text(config.read(query: "Team Name") ?? "Stanford Byers Center for Biodesign")
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)

            PageView(self.onboardingElements.map {
                InfoView(
                    logo: $0.logo,
                    title: $0.title,
                    description: $0.description,
                    color: self.color
                )
            })

            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    self.showingOnboard.toggle()
                }, label: {
                     Text("Join Study")
                        .padding(Metrics.paddingButtonLabel)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(self.color)
                        .cornerRadius(Metrics.radiusCornerButton)
                        .font(.system(size: 20, weight: .bold, design: .default))
                })
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)
                .sheet(
                    isPresented: $showingOnboard,
                    onDismiss: {
                        self.onComplete?()
                    },
                    content: {
                        OnboardingViewController().ignoresSafeArea(edges: .all)
                    }
                )
                Spacer()
            }
            
            HStack {
                Spacer()
                Button(action: {
                    self.showingLogin.toggle()
                }, label: {
                     Text("I'm a Returning User")
                        .padding(Metrics.paddingButtonLabel)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(self.color)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: Metrics.radiusCornerButton
                            ).stroke(self.color, lineWidth: 2))
                })
                .padding(.leading, Metrics.paddingHorizontalMain)
                .padding(.trailing, Metrics.paddingHorizontalMain)
                .sheet(
                    isPresented: $showingLogin,
                    onDismiss: {
                        self.onComplete?()
                    },
                    content: {
                        LoginExistingUserViewController().ignoresSafeArea(edges: .all)
                    }
                )
                Spacer()
            }
            Spacer()
        }
    }
}

struct InfoView: View {
    let logo: String
    let title: String
    let description: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 100, height: 100, alignment: .center)
                .padding(6)
                .overlay(
                    Text(logo)
                        .foregroundColor(.white)
                        .font(.system(size: 42, weight: .light, design: .default))
                )

            Text(title).font(.title)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
        }
    }
}

struct OnboardingUIView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingUIView()
    }
}
