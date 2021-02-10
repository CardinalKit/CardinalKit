//
//  ProfileDetail.swift
//  CardinalKit_Example
//
//  Created by Amrita Kaur on 2/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct ProfileDetail: View {
    var profile: Profile
    
    var body: some View {
        VStack(alignment: .center){
            ZStack{
                Image("RedBackground")
                    .resizable()
                    .frame(width: 400, height: 320, alignment: .center)
                    .offset(y: -50)
                
                VStack{
                    profile.image
                        .resizable()
                        .frame(width: 175, height: 175, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    
                    HStack{
                        Image("thumbtack")
                            .resizable()
                            //.aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text(profile.location)
                            .foregroundColor(.white)
                            
                    }
                    .offset(y: -10)
                }
                .offset(y: -25)
            }
            
            Text(profile.bio)
                .multilineTextAlignment(.center)
                .padding()
                .offset(y: -25)
            
            Divider()
                .padding(.horizontal)
            
            Spacer()
        
            Text(profile.email)
            
            Spacer()
        }
    }
}

struct ProfileDetail_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDetail(profile: profiles[0])
    }
}
