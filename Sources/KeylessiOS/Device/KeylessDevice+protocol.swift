//
//  KeylessDevice+protocol.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 27/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation
import CryptoSwift

//
//
//
//struct KeylessBLEMessages {
//    static let BLE_OPEN_DOORS:  UInt8 = 0x04
//    static let BLE_CLOSE_DOORS: UInt8 = 0x05
//
//    static let BLE_RESPONSE_ACTIVATING_DEVICE: UInt8 = 0x20
//    static let BLE_RESPONSE_OPENED_DOORS: UInt8 = 0x21
//    static let BLE_RESPONSE_CLOSED_DOORS: UInt8 = 0x22
//    static let BLE_RESPONSE_ERROR_SERIAL: UInt8 = 0xd0
//    static let BLE_RESPONSE_ERROR_PASSWORD: UInt8 = 0xd1
//}
//
//class KeylessBLEProtocol {
//    static let shared = KeylessBLEProtocol()
//
//    func handshake() -> [UInt8] {
//        return [0xff, 0x33, 0xff, 0x33]
//    }
//    //
//    //    func doors(open:Bool, crc: [UInt8]) throws -> [UInt8] {
//    //        if open {
//    //            return try prepareFrame(cmd: KeylessBLEMessages.BLE_OPEN_DOORS, data: crc)
//    //        }
//    //        return try prepareFrame(cmd: KeylessBLEMessages.BLE_CLOSE_DOORS, data: crc)
//    //    }
//    //
//    //    private func prepareFrame(cmd: UInt8, data: [UInt8]) throws -> [UInt8] {
//    //        // 0A 01 00 01 00 01 01
//    //
//    //        let serial = self.toBytes(PersistentData.shared.serial)
//    //        PersistentData.shared.serial += 1
//    //        let t = try AESLib.encrypt(serial + [cmd] + data)
//    //        return [0x0a] + serial + t
//    //    }
//    //
//    //    private func toBytes(_ nv:UInt16) -> [UInt8] {
//    //        return [UInt8(nv >> 8 & 0x00ff), UInt8(nv & 0x00ff)]
//}


internal enum DeviceAction: UInt8 {
    case open = 0x04
    case close = 0x05
    case seat = 0x06
    case headset = 0x07
}



extension KeylessDevice {
    // MARK: action methods
    internal func cmdPing() -> [UInt8] {
        return [UInt8](arrayLiteral: 0xff, 0x33, 0xff, 0x33)
    }
    
    internal func cmdAction(with action: DeviceAction) -> [UInt8]? {
        return prepareFrame(cmd: action.rawValue)
    }

    
    // MARK: private methods
    private func prepareFrame(cmd: UInt8) -> [UInt8]? {
        // 0A 01 00 01 00 01 01
        do {
            let currentSerial: Int = delegate?.serial ?? 0
            let serialBytes: [UInt8] = [UInt8(currentSerial >> 8), UInt8(currentSerial & 0xff)]
            let t = try encrypt(serialBytes + [cmd] + crc)
            return [0x0a] + serialBytes + t
        } catch {
            return nil
        }
    }

}

// MARK: Crytography methods.
extension KeylessDevice {
    //  PersistentData.shared.vehicle?.secret
    // PersistentData.shared.deviceUUID

    func getUpdatedSecret() -> Data {
        var s = Data(hex: delegate?.secret ?? "")
        let m: Data = delegate?.deviceUUID.data(using: .utf8) ?? Data()

        if s.count < 32 || m.count < 8 {
            return Data()
        }

        for i in 1..<33 {
            s[i] = s[i] ^ m[(i-1) % 8 + 2]
        }

        return s
    }

    func encrypt(_ data: [UInt8]) throws -> [UInt8] {
        let secret = getUpdatedSecret()
        if secret.count < 50 {
            return []
        }

        let key = secret[1...32]
        let iv = secret[33...48]
        let aes = try AES(key: Array(key), blockMode: CBC(iv: Array(iv)), padding: .pkcs7)
        return try aes.encrypt(data)
    }

    func decrypt(_ data: [UInt8]) throws -> [UInt8] {
        let secret = getUpdatedSecret()
        if secret.count < 50 {
            return []
        }

        let key = secret[1...32]
        let iv = secret[33...49]

        let aes = try AES(key: Array(key), blockMode: CBC(iv: Array(iv)), padding: .pkcs7)
        return try aes.decrypt(data)
    }

}
