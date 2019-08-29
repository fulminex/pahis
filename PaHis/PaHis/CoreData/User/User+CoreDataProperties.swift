//
//  User+CoreDataProperties.swift
//  
//
//  Created by Angel Herrera Medina on 8/29/19.
//
//

import Foundation
import CoreData


extension User: UniquedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var uid: Int32
    @NSManaged public var email: String
    @NSManaged public var name: String
    @NSManaged public var profilePicUrlRaw: String
    @NSManaged public var type: String
    @NSManaged public var token: String
    
    var profilePicUrl: URL? {
        return URL(string: profilePicUrlRaw)
    }

}
