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
            Button("Sign In With Google", action: googleSignInAction)
            Button("Sign in With Apple", action: appleSignInAction)
            Button("Sign in With Email and Password", action: emailSignInAction)
        }
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
