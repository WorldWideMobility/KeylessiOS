//
//  BleEnums.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation
import CoreBluetooth


struct BleUUID {
    static let serviceUUID = CBUUID(string: "0000FFE0-0000-1000-8000-00805F9B34FB")
    static let characteristicsUUID = [
        characteristics.communication,
        characteristics.providerFilter,
        characteristics.deviceName
    ]

    struct characteristics {
        static let deviceName = CBUUID(string: "2A25") // Serial Number String: WWM-DOCF..
        static let providerFilter = CBUUID(string: "2A28") // Sowftware Revision String: VRT
        static let communication = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")
        //    CBUUID(string: "2A20"), not used...

    }
    
}



