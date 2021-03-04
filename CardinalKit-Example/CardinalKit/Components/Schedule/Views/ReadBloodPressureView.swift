//
//  ReadBloodPressureView.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 3/2/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import HealthKit
import HealthKitUI

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
                if #available(iOS 14.0, *) {
                    let systolicPressureMeasurement = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(self.systolicPressure) ?? -1.0)
                    let diastolicPressureMeasurement = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(self.diastolicPressure) ?? -1.0)
                    
                    print(systolicPressureMeasurement)
                    print(diastolicPressureMeasurement)
                    
                    let systolicPressureDataObject = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!, quantity: systolicPressureMeasurement, start: Date(), end: Date())
                    let diastolicPressureDataObject = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!, quantity: diastolicPressureMeasurement, start: Date(), end: Date())
                    
                    HKHealthStore().save(systolicPressureDataObject) { success, error in
                        if error != nil {
                            print("Error: \(String(describing: error))")
                        }
                        if success {
                            print("Saved systolic successfully")
                        }
                    }
                    
                    HKHealthStore().save(diastolicPressureDataObject) { success, error in
                        if error != nil {
                            print("Error: \(String(describing: error))")
                        }
                        if success {
                            print("Saved diastolic successfully")
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
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
