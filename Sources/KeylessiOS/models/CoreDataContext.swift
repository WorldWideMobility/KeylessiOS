//
//  CoreDataContext.swift
//  MutuaiOS dev cliente
//
//  Created by Ubaldo Cotta on 11/05/2020.
//  Copyright © 2020 World Wide Mobility S.L. All rights reserved.
//

import CoreData

//class CoreDataContext {
//    var container: NSPersistentContainer
//
//    init() {
//        container = NSPersistentContainer(name: "DevicesFoundModel")
//        container.loadPersistentStores(completionHandler: { (_, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//    }
//
//    func save() {
//        let context = container.viewContext
//        if context.hasChanges {
//            do {
//                print(Date(), " = saving context")
//                try context.save()
//                print(Date(), " = context saved")
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
//}
