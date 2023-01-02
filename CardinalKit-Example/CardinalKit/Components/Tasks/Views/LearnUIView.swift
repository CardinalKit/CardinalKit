//
//  LearnUIView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CardinalKit. All rights reserved.
//

import SwiftUI

struct LearnUIView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("CKLogo")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.paddingHorizontalMain * 4)
                .padding(.trailing, Metrics.paddingHorizontalMain * 4)
                .accessibilityLabel(Text("Logo"))
            
            Text("""
                CardinalKit is a suite of tools designed to help you build a digital health app \
                experience from the ground up. It integrates with Firebase to provide full-stack solutions. \
                We hope you enjoy the love poured into this sample and make many great things with it!
                """)
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .regular, design: .default))
                .padding(.leading, Metrics.paddingHorizontalMain * 2)
                .padding(.trailing, Metrics.paddingHorizontalMain * 2)
            
            Spacer()
            
            Image("SBDLogoGrey")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.paddingHorizontalMain * 4)
                .padding(.trailing, Metrics.paddingHorizontalMain * 4)
                .accessibilityLabel(Text("Logo"))
        }
    }
}

struct LearnUIView_Previews: PreviewProvider {
    static var previews: some View {
        LearnUIView()
    }
}
