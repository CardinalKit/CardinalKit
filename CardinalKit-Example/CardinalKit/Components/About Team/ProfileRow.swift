//
//  ProfileRow.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 2/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct ProfileRow: View {
    var profile: Profile

    var body: some View {
        HStack {
            profile.image
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(5)
            Text(profile.name)

            Spacer()
        }
    }
}

struct ProfileRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileRow(profile: profiles[0])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
