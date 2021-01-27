//
//  BleDevice.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BleDeviceStatus {
    case notAvailable, found, connecting, connected, discovering, disconnected
}

class BleDevice: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral
    var status: BleDeviceStatus = .disconnected
    
    var deviceName: String?
    var deviceFilter: String?
    internal var ffe0: CBCharacteristic?
    
    
    var delegate: BleDeviceDelegate?
    weak var centralManager: CBCentralManager?
    
    var debugProtocol = false
    
    var deviceReady = false
    
    static func isValidDevice(peripheral: CBPeripheral) -> Bool {
        return peripheral.name?.starts(with: "WWM-") ?? false
    }
    
    var dateFormatter: DateFormatter

    init(peripheral: CBPeripheral, centralManager: CBCentralManager) {
        self.peripheral = peripheral
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss.SSS"
        super.init()
        self.peripheral.delegate = self
        self.centralManager = centralManager
    }
    
    // MARK: Logic stuff
    func discoverServices() {
        //print("## discoverServices", peripheral.services ?? "")
        peripheral.discoverServices([BleUUID.serviceUUID])
    }
    
    func disconnect() {
        centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    func write(message: [UInt8]) {
        guard let char = self.ffe0 else {
//            print("!! trying to write on a nil characteristic!!")
            return
        }
        if debugProtocol {
            print(dateFormatter.string(from: Date()),  "## >>", message.toHexString())
        }

        peripheral.writeValue(Data(message), for: char, type: .withoutResponse)
    }
    
    
    
    // MARK: Peripheral delegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        print("## services", peripheral.services ?? "")
        var found = false
        peripheral.services?.forEach({ (service) in
            if service.uuid == BleUUID.serviceUUID {
                peripheral.discoverCharacteristics(BleUUID.characteristicsUUID, for: service)
                found = true
            }
        })
        
        if !found {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        var totalCharFound = 0b000
//        print("## found characteristics for device", peripheral.identifier)

        service.characteristics?.forEach({ (char) in
//            print("## - characteristic", char)
            switch(char.uuid) {
            case BleUUID.characteristics.deviceName:
                peripheral.readValue(for: char)
                totalCharFound = totalCharFound | 0b001
                
            case BleUUID.characteristics.providerFilter:
                peripheral.readValue(for: char)
                totalCharFound = totalCharFound | 0b010
                
            case BleUUID.characteristics.communication:
                ffe0 = char
                peripheral.setNotifyValue(true, for: char)
                peripheral.writeValue(Data([0xff, 0x33, 0xff, 0x33]), for: char, type: .withoutResponse)
                totalCharFound = totalCharFound | 0b100
            default:
                break
            }
        })
        
        if totalCharFound != 0b111 {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard !deviceReady else {
            if debugProtocol {
                print(dateFormatter.string(from: Date()), "## <<", characteristic.value?.hexString ?? " <empty>")
            }
            delegate?.didRead(data: characteristic.value)
            return
        }
        
//        print(dateFormatter.string(from: Date()), "## didUpdate ", characteristic.uuid, error ?? "", characteristic.value?.hexString ?? "")
        
        if let value = characteristic.value {
            switch(characteristic.uuid) {
            case BleUUID.characteristics.deviceName:
                deviceName = value.string
                
            case BleUUID.characteristics.providerFilter:
                deviceFilter = value.string
                
            case BleUUID.characteristics.communication:
                if value.hexString == "FF33FF33" {
                    ffe0 = characteristic
                }
                
                break
                
            default:
                break
            }
            
            deviceReady = deviceName != nil && deviceFilter != nil && ffe0 != nil
            
            if deviceReady {
                // TODO: APAÑA ESTO!
//                BleDiscover.bleDeviceFound.accept(self)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if !deviceReady {
//            print("## didWrite", error ?? "")
        }
        delegate?.didWrite(wasOk: error == nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if !deviceReady {
//            print("## didUpdateNotification", error ?? "")
        }
        delegate?.didWrite(wasOk: error == nil)
    }
}

