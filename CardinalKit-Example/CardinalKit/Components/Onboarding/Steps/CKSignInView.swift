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

    let config = CKPropertyReader(file: "CKConfiguration")

    var body: some View {
        VStack {
            Spacer()

            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            if let appleSignInEnabled = config.readBool(query: "Sign In With Apple"),
                appleSignInEnabled {
                Button {
                    appleSignInAction()
                } label: {
                    Label("Sign In With Apple", image: "AppleLogo")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if let googleSignInEnabled = config.readBool(query: "Sign In With Google"),
                googleSignInEnabled {
                Button {
                    googleSignInAction()
                } label: {
                    Label("Sign In With Google", image: "GoogleLogo")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if let emailSignInEnabled = config.readBool(query: "Sign In With Email"),
                emailSignInEnabled {
                Button {
                    emailSignInAction()
                } label: {
                    Label("Sign In With Email", systemImage: "envelope")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
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
