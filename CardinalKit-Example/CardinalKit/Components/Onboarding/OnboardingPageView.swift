//
//  OnboardingPageView.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/7/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//

import SwiftUI

/// Allows the display of scrollable content on `OnboardingUIView`.
/// The content is defined in the `Onboarding` key in CKConfiguration.plist.
struct OnboardingPageView: View {
    let config = CKPropertyReader(file: "CKConfiguration")
    let color: Color
    var onboardingElements: [OnboardingElement] = []

    init() {
        self.color = Color(config.readColor(query: "Primary Color") ?? UIColor.primaryColor())

        if let onboardingData = config.readAny(query: "Onboarding") as? [[String: String]] {
            for data in onboardingData {
                guard let logo = data["Logo"],
                      let title = data["Title"],
                      let description = data["Description"] else {
                    continue
                }

                let element = OnboardingElement(
                    id: UUID(),
                    logo: Image(logo),
                    title: title,
                    description: description
                )

                self.onboardingElements.append(element)
            }
        }
    }

    var body: some View {
        /// This `TabView` shows pages of `OnboardingInfoView`s that contain content
        /// defined in the 'Onboarding' key within the CKConfiguration.plist.
        TabView {
            ForEach(onboardingElements, id: \.self) { element in
                OnboardingInfoView(
                    logo: element.logo,
                    title: element.title,
                    description: element.description,
                    color: self.color
                )
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

/// A section of content that is showed in a scrolling paged view.
struct OnboardingInfoView: View {
    let logo: Image
    let title: String
    let description: String
    let color: Color
    var body: some View {
        VStack(spacing: 10) {
            logo
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()

            Text(title).font(.title)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.leading, 40)
                .padding(.trailing, 40)
        }
    }
}

/// An element of content to be rendered in an `InfoView`.
struct OnboardingElement: Identifiable, Hashable {
    let id: UUID
    let logo: Image
    let title: String
    let description: String

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: OnboardingElement, rhs: OnboardingElement) -> Bool {
        return lhs.id == rhs.id
    }
}


struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView()
    }
}
