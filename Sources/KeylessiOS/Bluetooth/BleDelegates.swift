//
//  BleDelegates.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 25/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation

protocol BleDiscoverDelegate {
    func deviceFound()
    func deviceDisconnected()
}

protocol BleDeviceDelegate { // : NSObjectProtocol {
    func didRead(data: Data?)
    func didWrite(wasOk: Bool)
}
