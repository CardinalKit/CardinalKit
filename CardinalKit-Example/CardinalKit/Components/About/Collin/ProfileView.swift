//
//  ProfileView.swift
//  Assignment One
//
//  Created by CS342_Laptop_1 on 1/25/21.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        Image("IMG_9631")
            .resizable()
            .scaledToFit()
            .frame(width: 256)
            .clipShape(RoundedRectangle(cornerRadius: 50.0))
            .overlay(RoundedRectangle(cornerRadius: 50.0).stroke(Color.white, lineWidth: 4))
            .shadow(radius: 5)
            .padding(.top, 20)
        
        Text("Collin Schlager")
            .font(.title)
        
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: nil, content: {
            Text("schlager@stanford.edu")
            Text("CS BS '21; MS '22")
        })
            .padding()
            .font(.subheadline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
