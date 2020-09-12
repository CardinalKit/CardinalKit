//
//  WithdrawView.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct WithdrawView: View {
    @State var showWithdraw = false

    var body: some View {
        Button("Withdraw from Study") {
            self.showWithdraw.toggle()
        }
        .font(Font.body.bold())
        .foregroundColor(.red)
        .padding(.vertical)
        .sheet(isPresented: $showWithdraw) {
            WithdrawalVC()
        }
    }
}

struct WithdrawView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawView()
    }
}
