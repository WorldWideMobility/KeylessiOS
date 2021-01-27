//
//  DeviceEntity+methods.swift
//  MutuaiOS
//
//  Created by Ubaldo Cotta on 04/03/2020.
//  Copyright © 2020 World Wide Mobility S.L. All rights reserved.
//

import Foundation
import CoreData

public struct DeviceEntity {
    public var uuid: String?
    
}
extension DeviceEntity {
    static func newDevice() -> DeviceEntity {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return DeviceEntity()
//        }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        return DeviceEntity(context: managedContext)
        return DeviceEntity()
    }

    static func find(uuid: UUID) -> DeviceEntity? {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return nil
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest: NSFetchRequest<DeviceEntity> = DeviceEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid.uuidString)
//        do {
//            return try managedContext.fetch(fetchRequest).first
//        } catch let error as NSError {
//            print("No ha sido posible cargar \(error), \(error.userInfo)")
//        }
        return nil
    }

    static func find(name: String) -> DeviceEntity? {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return nil
//        }
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest: NSFetchRequest<DeviceEntity> = DeviceEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
//        do {
//            return try managedContext.fetch(fetchRequest).first
//        } catch let error as NSError {
//            print("No ha sido posible cargar \(error), \(error.userInfo)")
//        }
        return nil
    }


    func save() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        appDelegate.saveContext()
    }
}
