//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Angel Herrera Medina on 8/23/19.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var uid: Int32
    @NSManaged public var name: String

}
