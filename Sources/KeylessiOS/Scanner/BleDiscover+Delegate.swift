//
//  BleDiscover+Delegate.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import UIKit
import CoreBluetooth


extension BleDiscover: CBCentralManagerDelegate {
    // MARK: Central Manager Delegate
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard deviceUUID == peripheral.identifier || deviceUUID == nil && self.shouldConnect(peripheral: peripheral) else {
//            print("@@ didDiscover [ignored]", peripheral.identifier)
            return
        }
//        print("@@ didDiscover", peripheral.identifier)
        
        devices[peripheral.identifier] = BleDevice(peripheral: peripheral, centralManager: central)
        central.connect(peripheral, options: nil)
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        print("@@ didConnect", peripheral.identifier)
        devices[peripheral.identifier]?.discoverServices()
    }
    
    
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
//        print("@@ connectionEventDidOccur", peripheral.identifier, event)
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        print("@@ didDisconnectPeripheral", peripheral.identifier)
        devices.removeValue(forKey: peripheral.identifier)
        
        if peripheral.identifier == connectedDevice?.peripheral.identifier {
            connectedDevice = nil
            connectedDevice?.delegate = nil
            delegate?.deviceDisconnected()
            // se ha desconectado!!
        }
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        print("@@ didFailToConnect", peripheral.identifier)
        devices.removeValue(forKey: peripheral.identifier)
        
        // se ha desconectado!
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        print("@@ centralManagerDidUpdateState", central.state)
        
        switch central.state {
        case .unauthorized:
//            print("@@ BLE State: Unauthorized")
            KeylessManager.shared.bluetoothState.accept(.unauthorized)
            
        case .poweredOff:
            KeylessManager.shared.bluetoothState.accept(.off)
//            print("@@ BLE State: Powered OFF")
            
        case .poweredOn:
            KeylessManager.shared.bluetoothState.accept(.on)
//            print("@@ BLE State: Powered ON")
            
        default:
            break
//            print("@@ BLE State: other states", central.state)
        }
        
    }
    
    
}



