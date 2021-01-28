//
//  KeylessDevice.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 27/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//


import Foundation

enum KeylessLastAction {
    case userAction
    case ping
    case messages
    case idle
}

public enum KeylessDeviceStatus2 {
    case idle, sent, error, sending, connected, disconnected, connecting, searching
}

public protocol KeylessDeviceDelegate {
    // Messages
    func getNextMessage() -> String?
    func removeLastMessage()
    
    var status: KeylessDeviceStatus2 { get set }
    var serial: Int { get }
    var key: String { get }
    var hasVehicle: Bool { get }
    var secret: String { get }
    var deviceUUID: String { get }
}


public class KeylessDevice: BleDeviceDelegate {
    let device: BleDevice
    var crc = [UInt8]()
    
    var lastAction: KeylessLastAction = .idle
    var timerPing: Timer?
    
    
    var delegate: KeylessDeviceDelegate?
    
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

            if delegate?.getNextMessage() != nil {
                self.sendNextMessage()
            } else {
                delegate?.status = .idle
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
            delegate?.status = .sent
            lastAction = .idle

        case .userAction where cmd.hexString.starts(with: "ff33aa22"): // closed
            crc = Array(cmd[4...7])
            delegate?.status = .sent
            lastAction = .idle

            
        case .userAction: // error
            delegate?.status = .error
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
            delegate?.status = wasOk ? .sending : .error
            
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
            delegate?.status = .error
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
