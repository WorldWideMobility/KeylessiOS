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
        guard delegate?.hasVehicle == true, let dev = bleDiscover.connectedDevice else {
//        guard let dev = bleDiscover.connectedDevice, let vehicle == PersistentData.shared.vehicle.value else {
            return
        }
        
        device = KeylessDevice(with: dev)
        bleDiscover.stopScan()
        

        if delegate?.getNextMessage() != nil {
            delegate?.status = .connecting
            device?.sendNextMessage()
        } else {
            delegate?.status = .idle
        }
    }
    
    func deviceDisconnected() {
        print("deviceDisconnected")
        guard !bleDiscover.bleCM.isScanning else {
            return
        }
        device?.disconnect()
        device = nil
        delegate?.status = .searching
        bleDiscover.scan()
    }
}
