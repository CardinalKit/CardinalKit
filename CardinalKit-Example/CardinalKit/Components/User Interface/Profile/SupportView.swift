//
//  SupportView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct SupportView: View {
    let color: Color
    var phone: String

    var body: some View {
        HStack {
            Text("Support")
            Spacer()
            Text(phone)
                .foregroundColor(color)
        }
        .padding(.vertical)
        .onTapGesture {
            guard let url = URL(string: "tel://\(self.phone)") else { return }
            UIApplication.shared.open(url)

        }
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView(color: .accentColor, phone: "")
    }
}
