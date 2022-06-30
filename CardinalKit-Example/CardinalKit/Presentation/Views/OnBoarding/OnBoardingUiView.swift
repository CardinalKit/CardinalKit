//
//  OnboardingUIView.swift
//  CardinalKit_Example
//
//  Created by Varun Shenoy on 8/14/20.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import UIKit

struct OnboardingUIView: View {
    
    @ObservedObject var presenter = OnBoardingPresenter()
    
    let color: Color
    
    init() {
        let config = CKPropertyReader(file: "CKConfiguration")
        self.color = Color(config.readColor(query: "Primary Color"))
    }

    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image(presenter.viewModel.studyLogo)
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN*4)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN*4)
            
            Spacer(minLength: 2)
            
            Text(presenter.viewModel.studyTitle)
                .foregroundColor(self.color)
                .multilineTextAlignment(.center)
                .font(.system(size: 35, weight: .bold, design: .default))
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN)
            
            Text(presenter.viewModel.teamName)
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN)

            PageView(presenter.viewModel.onBoardingElements.map { InfoView(logo: $0.logo, title: $0.title, description: $0.description, color: self.color) })

            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    presenter.showNewUserSteps.toggle()
                }, label: {
                     Text("Join Study")
                        .padding(Metrics.PADDING_BUTTON_LABEL)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(self.color)
                        .cornerRadius(Metrics.RADIUS_CORNER_BUTTON)
                        .font(.system(size: 20, weight: .bold, design: .default))
                })
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN)
                .sheet(isPresented: $presenter.showNewUserSteps, onDismiss: {
                }, content: {
                    RegisterNewUserViewController().ignoresSafeArea(edges: .all)
                })
        
                Spacer()
            }
            
            HStack {
                Spacer()
                Button(action: {
                    presenter.showExistinUserSteps.toggle()
                }, label: {
                     Text("I'm a Returning User")
                        .padding(Metrics.PADDING_BUTTON_LABEL)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(self.color)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .overlay(
                                    RoundedRectangle(cornerRadius: Metrics.RADIUS_CORNER_BUTTON)
                                        .stroke(self.color, lineWidth: 2)
                            )
                })
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN)
                .sheet(isPresented: $presenter.showExistinUserSteps, onDismiss: {
                }, content: {
                    LoginExistingUserViewController().ignoresSafeArea(edges: .all)
                })
        
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
