//
//  CKSignInView.swift
//  CardinalKit_Example
//
//  Created by Vishnu Ravi on 1/7/23.
//  Copyright © 2023 CardinalKit. All rights reserved.
//

import SwiftUI

struct CKSignInView: View {
    let googleSignInAction: () -> Void
    let appleSignInAction: () -> Void
    let emailSignInAction: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Text("Sign In")
                .font(.title)

            Spacer()

            Button {
                appleSignInAction()
            } label: {
                Text("Sign In With Apple")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                googleSignInAction()
            } label: {
                Text("Sign In With Google")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                emailSignInAction()
            } label: {
                Text("Sign In With Email")
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct CKSignInView_Previews: PreviewProvider {
    static var previews: some View {
        CKSignInView(
            googleSignInAction: {},
            appleSignInAction: {},
            emailSignInAction: {}
        )
    }
}
