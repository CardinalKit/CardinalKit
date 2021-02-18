//
//  AboutUsView.swift
//  CardinalKit_Example
//
//  Created by Colton Swingle on 2/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct Fancy3DotsIndexView: View {
  
  // MARK: - Public Properties
  
  let numberOfPages: Int
  let currentIndex: Int
  
  
  // MARK: - Drawing Constants
  
  private let circleSize: CGFloat = 16
  private let circleSpacing: CGFloat = 12
  
  var primaryColor: Color
  
  private let smallScale: CGFloat = 0.6
  
  
  var body: some View {
    HStack(spacing: circleSpacing) {
      ForEach(0..<numberOfPages) { index in // 1
        Circle()
            .fill(currentIndex == index ? primaryColor : primaryColor.opacity(0.6)) // 2
        .scaleEffect(currentIndex == index ? 1 : smallScale)

        .frame(width: circleSize, height: circleSize)

        .transition(AnyTransition.opacity.combined(with: .scale)) // 3

        .id(index) // 4
      }
        
    }
    Spacer()
  }
}

struct AboutUsView: View {
    
    let dotColor: Color
    @State private var currentIndex = 0
    var body: some View {

        if #available(iOS 14.0, *) {
            TabView(selection: $currentIndex) {
                ColtonView()
                    .tag(0)
                CollinView()
                    .tag(1)
                HarryView()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .overlay(Fancy3DotsIndexView(numberOfPages: 3, currentIndex: currentIndex, primaryColor: dotColor))
           
            
        } else {
            // Fallback on earlier versions
        }
    }
}

struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView(dotColor: Color.blue)
    }
}
