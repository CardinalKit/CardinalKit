//
//  BLEManager.swift
//  CardinalKit_Example
//
//  Created by Harry Mellsop on 2/18/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    let corePeripheral: CBPeripheral
    var heartRate = false
    var bloodPressure = false
    var weight = false
    var services: [CBService:[CBCharacteristic]] = [:]
    var batteryLevel: Int = 0
}

//let heartRateServiceCBUUID = CBUUID(string: "0x180D")

let ServiceNameToCBUUID = [
    "Heart Rate" : CBUUID(string: "0x180D"),
    "Blood Pressure" : CBUUID(string: "0x1810"),
    "Enhanced Blood Pressure" : CBUUID(string: "0x2B34"),
    "Weight" : CBUUID(string: "0x181D")
]

let acceptableDeviceCBUUIDList = [
    ServiceNameToCBUUID["Heart Rate"]!,
    ServiceNameToCBUUID["Blood Pressure"]!,
    ServiceNameToCBUUID["Enhanced Blood Pressure"]!,
    ServiceNameToCBUUID["Weight"]!
]

class BLEManager: NSObject, CBCentralManagerDelegate, ObservableObject, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    var bloodPressurePeripheral: CBPeripheral!
    
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    @Published var connectedPeripherals = [Peripheral]()
    @Published var stateText: String = "Waiting for initialisation"
    
    // Identify when the CoreBluetooth Central Manager changes state; probably representing a change in client blueooth settings
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
        
        var alreadyDetected = false
        for alreadyDetectedPeriph in peripherals {
            if alreadyDetectedPeriph.corePeripheral.identifier == peripheral.identifier {
                alreadyDetected = true
                break
            }
        }
        if !alreadyDetected {
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, corePeripheral: peripheral)
            peripherals.append(newPeripheral)
        }
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
//        let newPeripheral = Peripheral(id: connectedPeripherals.count, name: peripheral.name ?? "Unknown Device", rssi: -1, corePeripheral: peripheral)
//        newPeripheral.corePeripheral.delegate = self
//        connectedPeripherals.append(newPeripheral)
        refreshConnectedDevices()
        discoverServices(peripheral: peripheral)
    }
    
    func refreshConnectedDevices() {
        
        // what should refreshConnectedDevices do?
        
        // - cull any devices that are no longer connected for whatever reason
        // - if devices are connected but aren't in the connectedDevices list, add them and schedule discovery of services and characteristics
        
        let detectedPeripherals = myCentral.retrieveConnectedPeripherals(withServices: acceptableDeviceCBUUIDList)
        
        var newConnectectedPeripherals: [Peripheral] = []
        
        for peripheral in connectedPeripherals {
            var stillConnected = false
            for detectedPeriph in detectedPeripherals {
                if peripheral.corePeripheral.identifier == detectedPeriph.identifier {
                    stillConnected = true
                    break
                }
            }
            if stillConnected {
                newConnectectedPeripherals.append(peripheral)
            }
        }
        
        connectedPeripherals.removeAll()
        connectedPeripherals = newConnectectedPeripherals
        
        for detectedPeriph in detectedPeripherals {
            var alreadyConnected = false
            for peripheral in connectedPeripherals {
                if peripheral.corePeripheral.identifier == detectedPeriph.identifier {
                    alreadyConnected = true
                    break
                }
            }
            if !alreadyConnected {
                let newConnectedPeripheral = Peripheral(id: connectedPeripherals.count, name: detectedPeriph.name ?? "Unknown Device", rssi: -1, corePeripheral: detectedPeriph)
                newConnectedPeripheral.corePeripheral.delegate = self
                connectedPeripherals.append(newConnectedPeripheral)
                
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Hmm, failed to connect")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        print(service)
        
        // find the relevant peripheral in the list
        let index = findPeripheralIndex(peripheral: peripheral)
    
        // update peripheral properties
        connectedPeripherals[index].services[service] = characteristics
        if service.uuid == ServiceNameToCBUUID["Heart Rate"] {
            connectedPeripherals[index].heartRate = true
        }
        if service.uuid == ServiceNameToCBUUID["Blood Pressure"] {
            connectedPeripherals[index].bloodPressure = true
        }
        if service.uuid == ServiceNameToCBUUID["Weight"] {
            connectedPeripherals[index].weight = true
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: "0x2A19") {
                peripheral.readValue(for: characteristic)
            }
        }
        
        // add the characteristic for the given service
//        for characteristic in characteristics {
//            print(characteristic)
//
//            if characteristic.properties.contains(.read) {
//                peripheral.readValue(for: characteristic)
//              print("\(characteristic.uuid): properties contains .read")
//            }
//            if characteristic.properties.contains(.notify) {
//              print("\(characteristic.uuid): properties contains .notify")
//            }
//        }
    }
    
    func findPeripheralIndex(peripheral: CBPeripheral) -> Int {
        for index in 0..<connectedPeripherals.count {
            if connectedPeripherals[index].corePeripheral.identifier == peripheral.identifier {
                return index
            }
        }
        return -1
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        // check the battery status
        if characteristic.uuid == CBUUID(string: "0x2A19") {
            let index = findPeripheralIndex(peripheral: peripheral)
            connectedPeripherals[index].batteryLevel = Int(characteristic.value?.first! ?? 0)
        }
        print(characteristic.value ?? "no value")
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        print("Attempting to discover services")
        peripheral.discoverServices(nil)
    }
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
    }
}
