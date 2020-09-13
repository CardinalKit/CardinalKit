//
//  HelpView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    let site: String

    var body: some View {
        Button("Help") {
            if let url = URL(string: self.site) {
                UIApplication.shared.open(url)
            }
        }
        .padding(.vertical)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(site: "apple.com")
    }
}
