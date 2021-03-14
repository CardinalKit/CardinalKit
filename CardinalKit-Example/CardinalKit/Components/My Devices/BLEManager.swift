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
    var bloodPressureCharacteristic: CBCharacteristic? = nil
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
    
    // Blood Pressure Specific Published Data
    @Published var systolicPressure: Float = 0.0
    @Published var diastolicPressure: Float = 0.0
    @Published var heartRate: Float = 0.0
    @Published var weight: Float = 0.0
    @Published var pressureUnits: String = "mmHg"
    @Published var dataGatheringComplete = false
    
    // Identify when the CoreBluetooth Central Manager changes state; probably representing a change in client Bluetooth settings
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
        } else {
            peripheralName = "Bluetooth Device"
        }
        
        // see if we have already detected this device; if we have, we need not list it again
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
        refreshConnectedDevices()
        discoverServices(peripheral: peripheral)
    }
    
    // Refresh the list of devices that are currently connected
    func refreshConnectedDevices() {
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
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Lost connection to peripheral")
        //refreshConnectedDevices()
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
            print(characteristic.uuid)
            if characteristic.uuid == CBUUID(string: "0x2A19") {
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == CBUUID(string: "0x2A35") {
                print("Attempting to read value for blood pressure")
                peripheral.setNotifyValue(true, for: characteristic)
                connectedPeripherals[index].bloodPressureCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error)
        }
        print("Successfully updated the notification state for \(characteristic.uuid)")
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
        print("Updated value function triggered")
        print(characteristic.uuid)
        // check the battery status
        if characteristic.uuid == CBUUID(string: "0x2A19") {
            let index = findPeripheralIndex(peripheral: peripheral)
            connectedPeripherals[index].batteryLevel = Int(characteristic.value?.first! ?? 0)
        } else if characteristic.uuid == CBUUID(string: "0x2A35") {
            print("Are we actually ever getting here?")
            let index = findPeripheralIndex(peripheral: peripheral)
            print("Reading blood pressure information from peripheral \(index)")
            print("Value is: \(characteristic.value)")
            getBloodPressureInfo(from: characteristic)
        }
        print(characteristic.value ?? "no value")
    }
    
    func getBloodPressureInfo(from characteristic: CBCharacteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        
        var ismmHg = true
        var supportsPulse = true
        
        // firstly, extract core data about the metrics from the flags byte
        if byteArray[0] & 0x01 == 0 {
            print("Units are mmHg")
            self.pressureUnits = "mmHg"
        } else {
            print("Units are kPa")
            self.pressureUnits = "kPa"
            ismmHg = false
        }
        
        if byteArray[0] & (0x01 << 1) == 0 {
            print("Time stamp flag not present")
        } else {
            print("Time stamp flag present")
        }
        
        if byteArray[0] & (0x01 << 2) == 0 {
            print("Pulse rate flag not present")
            supportsPulse = false
        } else {
            print("Pulse rate flag present")
        }
        
        if byteArray[0] & (0x01 << 3) == 0 {
            print("User ID flag not present")
        } else {
            print("User ID flag present")
        }
        
        if byteArray[0] & (0x01 << 4) == 0 {
            print("Measurement status not present")
        } else {
            print("Measurement status present")
        }
        
        if ismmHg {
            print("We've got mmHg")
            self.systolicPressure = Float(byteArray[1])
            self.diastolicPressure = Float(byteArray[3])
            
            print("Systolic: \(systolicPressure)")
            print("Diastolic: \(diastolicPressure)")
        } else {
            print("We've got kPA")
        }
        
        if supportsPulse {
            print("Reading pulse data")
            self.heartRate = Float(byteArray[5])
            print("Heart rate: \(self.heartRate)")
            print(Float(byteArray[4]))
            print(Float(byteArray[5]))
            print(Float(byteArray[6]))
            print(Float(byteArray[7]))
            print(Float(byteArray[8]))
            print(Float(byteArray[9]))
            print(Float(byteArray[10]))
        }
        dataGatheringComplete = true
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
