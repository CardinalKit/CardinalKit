//
//  RowDescription.swift
//  Assignment One
//
//  Created by Colton Swingle on 1/17/21.
//

import SwiftUI

struct RowDescription: View {
    var image: String
    var description: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(image)
                .resizable()
                .frame(width: 80, height: 80)
            Text(description)
                .font(.subheadline)
                .fontWeight(.regular)
        }
        .padding(10)
    }
}

struct RowDescription_Previews: PreviewProvider {
    static var previews: some View {
        RowDescription(image: "chess", description: "I like chess but sometimes chess can be a real pain in the ass and thats just the way it do be")
    }
}
