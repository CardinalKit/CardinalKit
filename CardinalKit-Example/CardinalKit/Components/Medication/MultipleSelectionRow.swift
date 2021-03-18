//
//  SwiftUIView.swift
//  CardinalKit_Example
//
//  Created by Rachel Naidich on 3/15/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
