//
//  DevicesView.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 2/17/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    let corePeripheral: CBPeripheral
}

//let heartRateServiceCBUUID = CBUUID(string: "0x180D")

let acceptableDeviceCBUUIDList = [CBUUID(string: "0x180D"), CBUUID(string: "0x1810"), CBUUID(string: "0x2B34"), CBUUID(string: "0x181D")]

class BLEManager: NSObject, CBCentralManagerDelegate, ObservableObject, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    var bloodPressurePeripheral: CBPeripheral!
    
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var stateText: String = "Waiting for initialisation"
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            stateText = "unknown"
        case .resetting:
            stateText = "resetting"
        case .unsupported:
            stateText = "unsupported"
        case .unauthorized:
            stateText = "unauthorized"
        case .poweredOff:
            stateText = "poweredOff"
            isSwitchedOn = false
        case .poweredOn:
            stateText = "poweredOn"
            isSwitchedOn = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown Device"
        }
        
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, corePeripheral: peripheral)
        peripherals.append(newPeripheral)
    }
    
    func startScanning() {
        print("startScanning")
        myCentral.scanForPeripherals(withServices: acceptableDeviceCBUUIDList, options: nil)
    }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func connect(peripheral: CBPeripheral) {
        print("Attempting Connection")
        myCentral.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Yay!  Connected!")
        // TODO: extend the logic to non-blood pressure stuff
        bloodPressurePeripheral = peripheral
        bloodPressurePeripheral.delegate = self
        bloodPressurePeripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Hmm, failed to connect")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        print("SERVICES!!!!!")
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print(service)
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
//              print("\(characteristic.uuid): properties contains .read")
            }
//            if characteristic.properties.contains(.notify) {
//              print("\(characteristic.uuid): properties contains .notify")
//            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print(characteristic.value ?? "no value")
    }
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
}

struct AddDeviceView: View {
    
    @ObservedObject var bleManager: BLEManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Searching for Bluetooth Devices").font(.title)
            
            List(bleManager.peripherals) { peripheral in
                HStack {
                    Text(peripheral.name)
                    Spacer()
                    Text(String(peripheral.rssi))
                }.onTapGesture {
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
        }
    }
}

struct DevicesView: View {
    
    @ObservedObject var bleManager = BLEManager()
    @State var presentAddDeviceMenu = false
    
    var body: some View {
        VStack (spacing: 10) {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            if bleManager.isSwitchedOn {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }
            
            Button("Add Device", action: {
                presentAddDeviceMenu = true
            })
            
            // Status goes here
            Text("Bluetooth status: " + bleManager.stateText)
                .foregroundColor(.red)
            
            Spacer()
            
            VStack (spacing: 10) {
                Button(action: {
                    self.bleManager.startScanning()
                }) {
                    Text("Start Scanning")
                }
                Button(action: {
                    self.bleManager.stopScanning()
                }) {
                    Text("Stop Scanning")
                }
            }.padding()
            
            Spacer()
        }.sheet(isPresented: $presentAddDeviceMenu, onDismiss: {presentAddDeviceMenu = false}, content: {
            AddDeviceView(bleManager: bleManager)
        })
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
}
