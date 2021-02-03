//
//  TagRow.swift
//  Assignment One
//
//  Created by Colton Swingle on 1/17/21.
//

import SwiftUI

struct TagRow: View {
    var body: some View {
        HStack {
            Text("cswingle@stanford.edu")
                .foregroundColor(.secondary)
            Spacer()
            if #available(iOS 14.0, *) {
                Link("Github: cswingle98", destination: URL(string: "https://github.com/cswingle98")!)
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            } else {
                // Fallback on earlier versions
            }
        }
        .padding()
        .font(.subheadline)
        
    }
}

struct TagRow_Previews: PreviewProvider {
    static var previews: some View {
        TagRow()
    }
}
