//
//  ChestStrapManager.swift
//  VascTrac
//
//  Created by Jeong Woo Ha on 4/20/18.
//  Copyright © 2018 VascTrac. All rights reserved.
//


// deals with Chest Strap that collects Heart Rate

import CoreBluetooth


class ChestStrapManager: NSObject {
    
    static let shared = ChestStrapManager()
    
    override init() {
        super.init()
    }
    
    // Bluetooth constants for Heart Rate
    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    
    // managers
    var centralManager: CBCentralManager?
    var heartRatePeripheral: CBPeripheral?
    
    var chestStrapUsage: Bool = false
    var isCollectingHR: Bool = false
    
    var delegate: ((Int) -> Void)? = nil
    
    func startCollecting(onCompletion: @escaping (_ heartRate: Int) -> Void) {
        if !chestStrapUsage {
            return
        }
        
        isCollectingHR = true
        
        centralManager?.delegate = self
        heartRatePeripheral?.delegate = self
        
        // discover heart rate services to collect HR data
        heartRatePeripheral?.discoverServices([heartRateServiceCBUUID])
        
        // collect HR and send over to PhoneMotionController
        self.delegate = onCompletion
    }
    
    
    func stopCollecting() {
        if !chestStrapUsage {
            return
        }
        
        isCollectingHR = false
        //delegate = nil
        
        //centralManager = nil
        //heartRatePeripheral = nil
    }
    
    
    func disconnectChestStrap() {
        
        if chestStrapUsage && heartRatePeripheral?.state == .connected {
            centralManager?.cancelPeripheralConnection(heartRatePeripheral!)
        }
        
        centralManager = nil
        heartRatePeripheral = nil
        chestStrapUsage = false
        isCollectingHR = false
        delegate = nil
    }
    
}


extension ChestStrapManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {}
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        heartRatePeripheral?.discoverServices([heartRateServiceCBUUID])
    }
}


extension ChestStrapManager: CBPeripheralDelegate {
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager?.connect(heartRatePeripheral!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            //let bodySensorLocation = bodyLocation(from: characteristic)
            break
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            if isCollectingHR {
                self.delegate?(bpm)
            }
            
        default:
            break
        }
    }
    
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
}
