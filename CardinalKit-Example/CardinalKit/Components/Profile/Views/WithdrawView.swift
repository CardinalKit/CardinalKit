//
//  WithdrawView.swift
//  CardinalKit_Example
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import SwiftUI

struct WithdrawView: View {
    let color: Color
    @State var showWithdraw = false
    
    init(color: Color) {
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text("Withdraw from Study").foregroundColor(self.color)
            Spacer()
            Text("›").foregroundColor(self.color)
        }.frame(height: 60)
            .contentShape(Rectangle())
            .gesture(TapGesture().onEnded({
                self.showWithdraw.toggle()
            })).sheet(isPresented: $showWithdraw, onDismiss: {
                
            }, content: {
                WithdrawalViewController()
            })
    }
}

struct WithdrawView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawView(color: Color.red)
    }
}
