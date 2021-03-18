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
    
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        VStack(alignment: .center){
            ZStack{
                Image("RedBackground")
                    .resizable()
                    .frame(width: ProfileDetail.screenWidth, height: ProfileDetail.screenHeight*(1/7), alignment: .center)
                    .offset(y: -ProfileDetail.screenHeight*(1/12))
                
                HStack{
                    profile.image
                        .resizable()
                        .frame(width: ProfileDetail.screenHeight*(1/6), height: ProfileDetail.screenHeight*(1/6), alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .offset(y: -ProfileDetail.screenHeight*(1/30))

                    if (profile.name.count < 13) {
                        Text(profile.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.leading)
                            .offset(y: -ProfileDetail.screenHeight*(1/30))
                    } else {
                        Text(profile.name)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .padding(.leading)
                            .offset(y: -ProfileDetail.screenHeight*(1/24))
                    }
                    Spacer()

                }
                .padding(.leading)
                
                
            }
            
            VStack{
                if(profile.bio != "") {
                    HStack{
                        Text("Bio")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding([.top, .leading])
                        Spacer()
                    }
                    
                    HStack{
                        Text(profile.bio)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                        Spacer()
                    }
                }
                
                if(profile.email != "" || profile.mobilephone != "" || profile.officephone != "" ||
                    profile.fax != "") {
                    HStack{
                        Text("Contact")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding([.top, .leading])
                        Spacer()
                    }
                
                    if(profile.email != "") {
                        HStack{
                            Text("Email:")
                                .padding(.leading)
                                .foregroundColor(.gray)
                            Text(profile.email)
                            Spacer()
                        }
                    }
                    if(profile.mobilephone != "") {
                        HStack{
                            Text("Mobile:")
                                .padding(.leading)
                                .foregroundColor(.gray)
                            Text(profile.mobilephone)
                            Spacer()
                        }
                    }
                    if(profile.officephone != "") {
                        HStack{
                            Text("Office:")
                                .padding(.leading)
                                .foregroundColor(.gray)
                            Text(profile.officephone)
                            Spacer()
                        }
                    }
                    if(profile.fax != "") {
                        HStack{
                            Text("Fax:")
                                .padding(.leading)
                                .foregroundColor(.gray)
                            Text(profile.fax)
                            Spacer()
                        }
                    }
                }
                
                if (profile.address_line1 != "" || profile.address_line2 != "" || profile.address_line3 != "") {
                    HStack{
                        Text("Address")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .padding([.top, .leading])
                        Spacer()
                    }

                    if (profile.address_line1 != "") {
                        HStack{
                            Text(profile.address_line1)
                                .padding(.leading)
                            Spacer()
                        }
                    }
                    if (profile.address_line2 != "") {
                        HStack{
                            Text(profile.address_line2)
                                .padding(.leading)
                            Spacer()
                        }
                    }
                    if (profile.address_line3 != "") {
                        HStack{
                            Text(profile.address_line3)
                                .padding(.leading)
                            Spacer()
                        }
                    }
                }
            }
            .offset(y: -ProfileDetail.screenHeight*(1/20))
            
            Spacer()
        }
    }
}

struct ProfileDetail_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDetail(profile: profiles[4])
    }
}
