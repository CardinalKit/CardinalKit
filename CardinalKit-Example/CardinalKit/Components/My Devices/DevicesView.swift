//
//  DevicesView.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 2/17/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct AddDeviceView: View {
    
    @ObservedObject var bleManager: BLEManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Searching for Bluetooth Devices").font(.title)
            
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    bleManager.connect(peripheral: peripheral.corePeripheral)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        }.onAppear {
            print("Add Bluetooth Device Menu Appeared")
            self.bleManager.startScanning()
        }.onDisappear {
            print("Add Bluetooth Device Menu Disappeared")
            self.bleManager.stopScanning()
        }.padding()
    }
}

struct ConnectedDeviceView: View {
    @ObservedObject var bleManager: BLEManager
    var peripheral: Peripheral
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(peripheral.name)
                Spacer()
//                Text(String(peripheral.rssi))
            }
//            Text("Available Services:")
//            ForEach(0..<peripheral.services.keys.count) { index in
//                Text(peripheral.services.keys[index])
//            }
            HStack {
                if (peripheral.heartRate) {
                    Image(systemName: "suit.heart.fill")
                }
                if (peripheral.weight) {
                    Image(systemName: "scalemass.fill")
                }
                if (peripheral.bloodPressure) {
                    Image(systemName: "arrow.up.heart.fill")
                }
                Spacer()
                
//                Image(systemName: "battery.0")
                Text("\(peripheral.batteryLevel)%")
                
                if (peripheral.batteryLevel >= 0 && peripheral.batteryLevel < 20) {
                    Image(systemName: "battery.0")
                } else if peripheral.batteryLevel < 40 {
                    Image(systemName: "battery.25")
                } else {
                    Image(systemName: "battery.100")
                }
            }
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("Click detected")
            print(acceptableDeviceCBUUIDList)
            print(peripheral.services)
//            bleManager.discoverServices(peripheral: peripheral.corePeripheral)
        }
    }
}

struct DevicesView: View {
    
    @ObservedObject var bleManager = BLEManager()
    @State var presentAddDeviceMenu = false
    @State var firstLoad = true
    
    var body: some View {
        VStack (spacing: 10) {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            List(bleManager.connectedPeripherals) { peripheral in
                ConnectedDeviceView(bleManager: bleManager, peripheral: peripheral)
            }
            
//            if bleManager.isSwitchedOn {
//                Text("Bluetooth is switched on")
//                    .foregroundColor(.green)
//            }
//            else {
//                Text("Bluetooth is NOT switched on")
//                    .foregroundColor(.red)
//            }
            
            Button(action: {
                presentAddDeviceMenu = true
            }) {
                HStack {
                    Spacer()
                    Text("Add Device")
                    Spacer()
                }
            }
            .buttonStyle(RoundedCornerGradientButtonStyle())
            
            Spacer()
        }.sheet(isPresented: $presentAddDeviceMenu, onDismiss: {presentAddDeviceMenu = false}, content: {
            AddDeviceView(bleManager: bleManager)
        })
        .onAppear {
            bleManager.refreshConnectedDevices()
        }.padding()
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
}
