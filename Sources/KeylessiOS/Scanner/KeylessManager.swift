//
//  BleDevieManager.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation

//enum KeylessStatus {
//    case disconnected
//    case login
//    case ping
//    case nop
//}

public enum KeylessDeviceStatus {
    case disconnected, searching, connecting, idle, working
}


public enum DeviceCommandState {
    case sending, sent, error
}

public enum BluetoothState {
    case on, off, unauthorized
}



class KeylessManager: NSObject {
    static let shared = KeylessManager()
    
    override init() {
        super.init()
        bleDiscover.delegate = self
//        bluetoothState.bind(onNext: bluetoothStateChanged).disposed(by: disposeBag)
    }

    var delegate: KeylessDeviceDelegate?

    var bleDiscover = BleDiscover()

    var device: KeylessDevice? = nil
    
    var timerPing: Timer?
    
    var deviceName: String? = nil {
        didSet {
//            guard oldValue != deviceName else {
//                return
//            }
            if deviceName != nil {
                bleDiscover.deviceName = deviceName
                bleDiscover.scan()
            } else if oldValue != nil {
                bleDiscover.connectedDevice = nil
                delegate?.status = .disconnected
                bleDiscover.stopScan()
                device?.disconnect()
                device = nil
            }
        }
    }
    
//    public var commandStatus = PublishRelay<DeviceCommandState>()
//    public var deviceStatus = BehaviorRelay<KeylessDeviceStatus>(value: .disconnected)
//    public var bluetoothState = BehaviorRelay<BluetoothState>(value: .on)
    
    func bluetoothStateChanged(_ state: BluetoothState) {
        if state != .on {
            deviceName = nil
        }
    }
}
