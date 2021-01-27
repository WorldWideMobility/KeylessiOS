//
//  KeylessDevice.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 27/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//


import Foundation

internal enum KeylessLastAction {
    case userAction
    case ping
    case messages
    case idle
}

protocol KeylessDeviceDelegate {
    // Messages
    func getNextMessage() -> String?
    func removeLastMessage()
}


class KeylessDevice: BleDeviceDelegate {
    internal let device: BleDevice
    internal var crc = [UInt8]()
    
    internal var lastAction: KeylessLastAction = .idle
    internal var timerPing: Timer?
    
    
    init(with device: BleDevice) {
        self.device = device
        self.device.delegate = self
        timerPing = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in self.ping() })
        if let cmd = self.device.ffe0?.value {
            crc = Array(cmd[4...7])
        }

    }
    
    private func ping() {
        if lastAction == .idle {
            lastAction = .ping
            self.device.write(message: cmdPing())
        }
    }
    
    func didRead(data: Data?) {
        guard let cmd = data else { return }
        
        switch lastAction {
            
        case .messages where cmd.hexString.starts(with: "ff33aa03"):
            crc = Array(cmd[4...7])

            if PersistentData.shared.vehicleMessages.count > 0 {
//            if PersistentData.shared.vehicle.value?.data?.count ?? 0 > 0 {
                self.sendNextMessage()
            } else {
                KeylessManager.shared.deviceStatus.accept(.idle)
                lastAction = .idle
            }
            
        case .messages:
            print(cmd)
            
        case .userAction where cmd.hexString.starts(with: "ff33aa20"): // activating
            crc = Array(cmd[4...7])
            //KeylessManager.shared.commandStatus.accept(.sending)
            break
            
        case .userAction where cmd.hexString.starts(with: "ff33aa21"): // opened
            crc = Array(cmd[4...7])
            KeylessManager.shared.commandStatus.accept(.sent)
            lastAction = .idle

        case .userAction where cmd.hexString.starts(with: "ff33aa22"): // closed
            crc = Array(cmd[4...7])
            KeylessManager.shared.commandStatus.accept(.sent)
            lastAction = .idle

            
        case .userAction: // error
            KeylessManager.shared.commandStatus.accept(.error)
            lastAction = .idle

        case .ping where cmd.hexString.starts(with: "ff33ff33") :
            crc = Array(cmd[4...7])
            lastAction = .idle
            // send queued data or notify that the vehice is ready
            
//        case .working where bytes.starts(with: [0xff, 0x33, 0xaa, 0x20]):
//            lastcrc = Array(bytes[4...7])
//            NotificationCenter.default.post(name: .car, object:  bytes[3])
            //self.startRefreshStatusTimer()

        default:
            break
        }
        
        //KeylessManager.shared.commandStatus.accept(.sent)
    }
    
    func didWrite(wasOk: Bool) {

        switch lastAction {
        case .userAction:
            KeylessManager.shared.commandStatus.accept(wasOk ? .sending : .error)
            
        default:
            break
        }

    }

    
    @discardableResult
    func send(command action: DeviceAction) -> Bool {
        guard lastAction == .idle else {
            return false
        }
        if let data = cmdAction(with: action) {
            self.lastAction = .userAction
            self.device.write(message: data)
            return true
        } else {
            
            KeylessManager.shared.commandStatus.accept(.error)
        }
        return false
    }
    
    
    func disconnect() {
        self.device.disconnect()
        self.device.delegate = nil
    }
    
    deinit {
        print("#$%#$%#$%   DEINIT")
    }
}
