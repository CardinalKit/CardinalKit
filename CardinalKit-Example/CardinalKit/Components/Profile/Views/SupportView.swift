//
//  SupportView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct SupportView: View {
    let color: Color
    var phone = ""
    
    init(color: Color, phone: String) {
        self.color = color
        self.phone = phone
    }
    
    var body: some View {
        HStack {
            Text("Support")
            Spacer()
            Text(self.phone).foregroundColor(self.color)
        }
        .frame(height: 60)
        .contentShape(Rectangle())
        .gesture(TapGesture().onEnded({
            let telephone = "tel://"
                let formattedString = telephone + self.phone
            guard let url = URL(string: formattedString) else { return }
            UIApplication.shared.open(url)
        }))
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView(color: Color.red, phone: "+1 (650)-000-0000")
    }
}
