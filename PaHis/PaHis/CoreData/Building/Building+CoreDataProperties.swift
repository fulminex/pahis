//
//  Building+CoreDataProperties.swift
//  
//
//  Created by Angel Herrera Medina on 8/23/19.
//
//

import Foundation
import CoreData


extension Building {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Building> {
        return NSFetchRequest<Building>(entityName: "Building")
    }

    @NSManaged public var uid: Int32
    @NSManaged public var name: String
    @NSManaged public var address: String
    @NSManaged public var detail: String
    @NSManaged public var documents: [String]
    @NSManaged public var images: [String]
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var state: String
    @NSManaged public var category: Category

}
