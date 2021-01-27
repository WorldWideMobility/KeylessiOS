//
//  KeylessManager+Discovery.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation

extension KeylessManager: BleDiscoverDelegate {
    
    func deviceFound() {
        guard let vehicle = PersistentData.shared.vehicle.value, let dev = bleDiscover.connectedDevice else {
//        guard let dev = bleDiscover.connectedDevice, let vehicle == PersistentData.shared.vehicle.value else {
            return
        }
        
        device = KeylessDevice(with: dev)
        bleDiscover.stopScan()
        
        if PersistentData.shared.vehicleMessages.count > 0 {
//        if vehicle.dataMessages.count > 0 {
            self.deviceStatus.accept(.connecting)
            device?.sendNextMessage()
        } else {
            self.deviceStatus.accept(.idle)
        }
    }
    
    func deviceDisconnected() {
        print("deviceDisconnected")
        guard !bleDiscover.bleCM.isScanning else {
            return
        }
        device?.disconnect()
        device = nil
        self.deviceStatus.accept(.searching)
        bleDiscover.scan()
    }
}
