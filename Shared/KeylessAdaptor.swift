//
//  KeylessAdaptor.swift
//  KeylessiOS
//
//  Created by Ubaldo Cotta on 28/1/21.
//

import Foundation
import KeylessiOS
import CoreLocation


class KeylessAdaptor: KeylessDeviceDelegate {
    func getNextMessage() -> String? {
        return nil
    }

    func removeLastMessage() {

    }

    var status: KeylessDeviceStatus2 = .idle {
        didSet {

        }
    }

    var serial: Int = 10 {
        didSet {
        }
    }

    var key: String = "54b7689ec0ab86334270a0c4990560cb82d0a1bc2cc8d8bca0da6c656f64236d71b79703708d9facc14590526572c100007a"

    var hasVehicle: Bool = true

    var secret: String = "54b7689ec0ab86334270a0c4990560cb82d0a1bc2cc8d8bca0da6c656f64236d71b79703708d9facc14590526572c100007a"

    var deviceUUID: String = "WWM-D0CF5EB23CAB"


    init() {
        KeylessManager.shared.delegate = self
        CLLocationManager().requestWhenInUseAuthorization()
        KeylessManager.shared.deviceName = deviceUUID
    }
}


