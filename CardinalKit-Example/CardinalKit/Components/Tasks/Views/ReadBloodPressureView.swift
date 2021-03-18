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
    @State var actionItemSelected: Bool = false
    @State var useCuff: Bool = true
    @State var presentAddDeviceMenu = false
    @State var deviceChosen = false
    @State var uploadSelected = false
    
    @ObservedObject var bleManager = BLEManager()
    
    func submitMetrics() {
        if useCuff {
            // extract data from BP cuff
        }
        print("I'm gonna have to Kermit")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Blood Pressure")
                .font(.title)
                .padding(.bottom, 10.0)
            Text("You can manually enter blood pressure readings from traditional cuffs, or use a Bluetooth connected smart cuff.")
                .font(.body)
                .padding(.bottom, 10.0)
            
            if !actionItemSelected {
                Spacer()
                Text("I would like to:")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.headline)
                    .padding(.bottom, 10)
                Button(action: {
                    actionItemSelected = true
                    useCuff = true
                }) {
                    HStack {
                        Spacer()
                        Text("Read Pressure from Bluetooth")
                        Spacer()
                    }
                }
                .buttonStyle(RoundedCornerGradientButtonStyle())
                
                Button(action: {
                    actionItemSelected = true
                    useCuff = false
                }) {
                    HStack {
                        Spacer()
                        Text("Enter Pressure Manually")
                        Spacer()
                    }
                }
                .buttonStyle(RoundedCornerGradientButtonStyle())
            }
            
            if actionItemSelected && useCuff {
                if !deviceChosen {
                    Spacer()
                    Button(action: {
                        presentAddDeviceMenu = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Connect a device")
                            Spacer()
                        }
                    }
                    .buttonStyle(RoundedCornerGradientButtonStyle())
                    Spacer()
                } else if !bleManager.dataGatheringComplete {
                    Spacer()
                    Text("Device has been chosen!")
                    List(bleManager.connectedPeripherals) { peripheral in
                        ConnectedDeviceView(bleManager: bleManager, peripheral: peripheral)
                    }
                    Text("Please follow the instructions provided by your Smart Cuff manufacturer, and begin the blood pressure test.")
                    Text("Only select the following button when the test has been completed.")
                    Spacer()
                    if !uploadSelected {
                        Button(action: {
                            bleManager.connect(peripheral: bleManager.connectedPeripherals[0].corePeripheral)
                            uploadSelected = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Upload data from Cuff")
                                Spacer()
                            }
                        }
                        .buttonStyle(RoundedCornerGradientButtonStyle())
                    } else if uploadSelected {
                        Button(action: {
                            print("No-op")
                        }) {
                            HStack {
                                Spacer()
                                Text("Uploading data...")
                                Spacer()
                            }
                        }
                        .buttonStyle(RoundedCornerGradientButtonStyle())
                    }
                    Spacer()
                } else if bleManager.dataGatheringComplete {
                    Spacer()
                    Text("Systolic Blood Pressure = \(self.bleManager.systolicPressure)")
                    Text("Diastolic Blood Pressure = \(self.bleManager.diastolicPressure)")
                    Text("Heart Rate = \(self.bleManager.heartRate)")
                    Text("Units = \(self.bleManager.pressureUnits)")
                    Spacer()
                    Button(action: {
                        submitMetrics()
                    }) {
                        HStack {
                            Spacer()
                            Text("Submit these measurements")
                            Spacer()
                        }
                    }
                    .buttonStyle(RoundedCornerGradientButtonStyle())
                    Spacer()
                }
            }
            
            
            
        }.sheet(isPresented: $presentAddDeviceMenu, onDismiss: {
                    presentAddDeviceMenu = false
                    deviceChosen = true
            
        }, content: {
            AddDeviceView(bleManager: bleManager)
        })
        .padding()
        
    }
}
