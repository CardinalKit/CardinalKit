//
//  ReadBloodPressureView.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 3/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI

struct ReadBloodPressureView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var parent: BloodPressureItemViewController
    
    @State var systolicPressure = ""
    @State var diastolicPressure = ""
    @State var cuffConnected: Bool = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Blood Pressure")
                .font(.title)
                .padding(.bottom, 10.0)
            Text("You can manually enter blood pressure readings from traditional cuffs, or use a Bluetooth connected smart cuff.")
                .font(.body)
                .padding(.bottom, 10.0)
            if cuffConnected {
                Text("If you wish to use your connected Blood Pressure cuff, push the 'Read Pressure from Bluetooth' button below to automatically populate the data fields.")
            }
            else {
                Text("If you wish to connect a Bluetooth connected smart cuff, swipe this view away and pair it in the 'My Devices' section.")
            }
            Spacer()
            Group {
                Text("Systolic Blood Pressure")
                TextField("", text: $systolicPressure)
                    .keyboardType(.numberPad)
                Text("Diastolic Blood Pressure")
                TextField("", text: $diastolicPressure)
                    .keyboardType(.numberPad)
            }
            Spacer()
            if cuffConnected {
                Button(action: {
                    print("Blood Pressure Submitted")
                }) {
                    HStack {
                        Spacer()
                        Text("Read Pressure from Bluetooth")
                        Spacer()
                    }
                }
                .buttonStyle(RoundedCornerGradientButtonStyle())
            }
            Button(action: {
                print("Blood Pressure Submitted")
            }) {
                HStack {
                    Spacer()
                    Text("Submit Pressure")
                    Spacer()
                }
            }
            .buttonStyle(RoundedCornerGradientButtonStyle())
            
        }.padding()
        
    }
}
