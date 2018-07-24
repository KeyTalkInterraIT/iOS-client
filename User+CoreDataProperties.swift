//
//  User+CoreDataProperties.swift
//  
//
//  Created by Paurush on 6/18/18.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var service: String?
    @NSManaged public var username: String?

}
