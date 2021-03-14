//
//  TeamUIView.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 2/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct TeamUIView: View {
    var body: some View {
        
        VStack (alignment: .leading){
            NavigationView {
                List(profiles) { profile in
                    NavigationLink(destination: ProfileDetail(profile: profile)) {
                        ProfileRow(profile: profile)
                    }
                }
                .navigationBarTitle("Care Team")
            }
        }
        
    }
}

struct TeamUIView_Previews: PreviewProvider {
    static var previews: some View {
        TeamUIView()
    }
}
