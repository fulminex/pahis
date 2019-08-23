//
//  PersistenceManager.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 8/23/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation
import CoreData

public protocol UniquedObject {
    var uid: Int32 { get set }
}

class PersistenceManager {
    private init() {}
    static let shared = PersistenceManager()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil) -> [T]{
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = predicate
        do {
            let fetchedObjects = try context.fetch(fetchRequest) as? [T]
            return fetchedObjects ?? [T]()
        } catch {
            print(error)
            return[T]()
        }
    }
    
    func fetchSingle<T: NSManagedObject>(_ objectType: T.Type, uid: Int32) -> T? {
        let predicate = NSPredicate(format: "uid == %@", String(uid))
        return fetch(objectType, predicate: predicate).first
    }
    
    func fetchSingleOrCreate<T: NSManagedObject>(_ objectType: T.Type, uid: Int32) -> T where T:UniquedObject {
        guard let obj = fetchSingle(objectType, uid: uid) else {
            var obj = T(context: context)
            obj.uid = uid
            return obj
        }
        return obj
    }
    
    func delete<T: NSManagedObject>(_ obj: T) {
        context.delete(obj)
    }
 }
