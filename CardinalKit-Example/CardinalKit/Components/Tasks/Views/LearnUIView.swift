//
//  LearnUIView.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct LearnUIView: View {
    var body: some View {
        VStack(spacing: 10) {
//            Image("CKLogo")
//                .resizable()
//                .scaledToFit()
//                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN*4)
//                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN*4)
            Spacer()
            Text("Digital Professional Development")
                .font(.system(size: 18))
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN*2)
            Text("Digital Professional Development (“Digital-PD”), is a Stanford University study on designing efficient professional development activities. Over the course of each workday, you have been asked to complete a series of additional activities designed to resemble tasks which would ordinarily be part of your workflow. Additionally, you have been asked to complete questionnaires asking opinions of the training exercises at various times throughout the day. You have been asked to wear a device on your wrist to monitor physiological activity during the training exercises, and this application will be used to track where and when you choose to complete your professional development exercises. If you have any questions, do not hesitate to reach out to Michael by email at coopermj@stanford.edu, or by phone at 555-555-5555.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN*2)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN*2)
            
            Spacer()
            
            Image("SBDLogoGrey")
                .resizable()
                .scaledToFit()
                .padding(.leading, Metrics.PADDING_HORIZONTAL_MAIN*4)
                .padding(.trailing, Metrics.PADDING_HORIZONTAL_MAIN*4)
            
        }
    }
}

struct LearnUIView_Previews: PreviewProvider {
    static var previews: some View {
        LearnUIView()
    }
}
