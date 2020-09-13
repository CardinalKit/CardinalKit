//
//  PlainNavigationLink.swift
//  TrialX
//
//  Created by Apollo Zhu on 9/13/20.
//  Copyright © 2020 TrialX. All rights reserved.
//

import SwiftUI

struct PlainNavigationLink<Label, Destination> : View where Label : View, Destination : View {
    var iOS13: some View {
        ZStack {
            label()

            NavigationLink(destination: destination) {
                EmptyView()
            }
        }
    }

    var body: some View {
        #if canImport(UniformTypeIdentifiers)
        Group {
            if #available(iOS 14, *) {
                NavigationLink(destination: destination, label: label)
            } else {
                iOS13
            }
        }
        #else
        return iOS13
        #endif
    }

    let destination: Destination
    let label: () -> Label
    init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.destination = destination
        self.label = label
    }
}

struct PlainNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        PlainNavigationLink(destination: Text("hello")) {
            Text("World")
        }
    }
}
