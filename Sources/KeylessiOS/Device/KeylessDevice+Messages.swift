//
//  KeylessDevice+Messages.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 27/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation

extension KeylessDevice {
    internal func sendNextMessage() {
        guard let vehicle = PersistentData.shared.vehicle.value, let message = delegate?.getNextMessage() else {
            self.device.centralManager?.cancelPeripheralConnection(self.device.peripheral)
//            self.disconnect()
            return
        }
        
        delegate?.removeLastMessage()
        
        var data = Data(hex: message).bytes
        let header = data.prefix(4)
        data.removeFirst(4)
        
        lastAction = .messages
 
        while data.count > 0 {
            var message = Array<UInt8>(header)
            message.append(contentsOf: data.prefix(60))
            data.removeFirst(message.count - 4)

            device.write(message: message)
            Thread.sleep(forTimeInterval: 0.05)
        }
//        vehicle.data?.remove(at: 0)
//        self.startTimer()
        return
    }
//    
//    
//    internal func sendDataMessage() {
//        self.resetTimer()
//        self.step = .working
//        
//        guard let vehicle = PersistentData.shared.vehicle, vehicle.dataMessages.count != 0 else {
//            self.startRefreshStatusTimer()
//            return
//        }
//        
//        var data = Data(hex: vehicle.dataMessages[0]).bytes
//        //if data.count < 30 {
//        //    resetCommunications()
//        //    return
//        //}
//        
//        let header = data.prefix(4)
//        data.removeFirst(4)
//        
//        
//        while data.count > 0 {
//            var message = Array<UInt8>(header)
//            message.append(contentsOf: data.prefix(60))
//            data.removeFirst(message.count - 4)
//            
//            if !self.bluetoothSerial.sendBytesToDevice(message) {
//                print("@@ unable to send splitted 0C data message", message)
//                resetCommunications()
//                return
//            }
//            
//            Thread.sleep(forTimeInterval: 0.05)
//        }
//        vehicle.dataMessages.remove(at: 0)
//        PersistentData.shared.updateAccount()
//        PersistentData.shared.storeVehicle()
//        //        print("@@ startTimer on sendDataMessage")
//        self.startTimer()
//    }
    
    
}
