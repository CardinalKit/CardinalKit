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

    let config = CKConfig.shared

    var body: some View {
        VStack {
            Spacer()

            Text("Sign In")
                .font(.title)

            Spacer()

            Button {
                appleSignInAction()
            } label: {
                Label("Sign In With Apple", image: "AppleLogo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                googleSignInAction()
            } label: {
                Label("Sign In With Google", image: "GoogleLogo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                emailSignInAction()
            } label: {
                Label("Sign In With Email", systemImage: "envelope")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
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
