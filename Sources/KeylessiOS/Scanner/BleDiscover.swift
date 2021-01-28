//
//  BLEdiscover.swift
//  test BLE v2.0
//
//  Created by Ubaldo Cotta on 24/02/2020.
//  Copyright © 2020 World Wide Mobility. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreData


class BleDiscover: NSObject {
    var bleCM: CBCentralManager!
    var devices = [UUID: BleDevice]()
    var ignoreDevices = [UUID]()
    var connectedDevice: BleDevice?
    
    var timerRestartScan: Timer?
    
    var delegate: BleDiscoverDelegate?
    
    var deviceName: String?
    var deviceUUID: UUID?
    
    var wellKnownDevices = [NSManagedObject]()

    
    // Reeactive cositas
//    static let bleDeviceFound = BehaviorRelay<BleDevice?>(value: nil)

    // MARK: Logic methods
    override init() {
        super.init()
        bleCM = CBCentralManager(delegate: self, queue: nil)
//        BleDiscover.bleDeviceFound.bind(onNext: deviceReady).disposed(by: disposeBag)
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceReady(_:)), name: .deviceFound, object: nil)
    }
    
    func shouldConnect(peripheral: CBPeripheral) -> Bool {
        
        guard !ignoreDevices.contains(peripheral.identifier), devices.index(forKey: peripheral.identifier) == nil else {
            return false
        }
        
        if !BleDevice.isValidDevice(peripheral: peripheral) {
            ignoreDevices.append(peripheral.identifier)
            return false
        }
        
        return (deviceUUID != nil && peripheral.identifier != deviceUUID || deviceUUID == nil)
    }

    func scan() {
        guard let name=deviceName, connectedDevice == nil else {
            return
        }

        if let device = DeviceEntity.find(name: name), let uuid = device.uuid {
            deviceUUID = UUID(uuidString: uuid)
        }
        if bleCM.isScanning {
            bleCM.stopScan()
        }
        
        timerRestartScan?.invalidate()
        timerRestartScan = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { (timer) in
            self.restartScan()
        })
        
        bleCM.scanForPeripherals(withServices: nil, options: nil)
//        bleCM.scanForPeripherals(withServices: [BleUUID.serviceUUID], options: nil)
        bleCM.retrieveConnectedPeripherals(withServices: [BleUUID.serviceUUID]).forEach { (peripheral) in
            self.centralManager(self.bleCM, didDiscover: peripheral, advertisementData: [:], rssi: 0)
        }
        
        
    }
    
    func stopScan() {
        timerRestartScan?.invalidate()
        timerRestartScan = nil
        bleCM.stopScan()
        devices.forEach { (k, v) in
            self.bleCM.cancelPeripheralConnection(v.peripheral)
        }
    }
    
    private func restartScan() {
        guard bleCM.isScanning else {
            return
        }
        bleCM.stopScan()
        scan()
    }
    

    func deviceReady(_ deviceFound: BleDevice?) {
        // Is the device still in devices?
        
        
        guard let dev = deviceFound, devices[dev.peripheral.identifier] != nil else {
            deviceFound?.disconnect()
            return
        }

        fatalError("Incorpora coredata aquí de nuevo!!!")
        if deviceUUID == nil {
            // UC20200511 :: DISABLED UNTIL CONTEXT'LL BE ADDED HERE.
            // No se usa el descubrimiento de dispositivos de momento.
            // In discover we store all devices, with deviceUUID is not necessary because
            // we know how are looking for.
//            let tmp = DeviceEntity.newDevice()
//            tmp.name = dev.deviceName
//            tmp.uuid = dev.peripheral.identifier.uuidString
//            tmp.save()
        }

        
        // Is the device that we are looking for?
        guard bleCM.isScanning, connectedDevice == nil, dev.deviceName == self.deviceName else {
            // Remove from db.
            deviceFound?.disconnect()
            devices.removeValue(forKey: dev.peripheral.identifier)
            return
        }
        
        connectedDevice = dev
        devices.removeValue(forKey: dev.peripheral.identifier)
        
        delegate?.deviceFound()
    }


    
}



