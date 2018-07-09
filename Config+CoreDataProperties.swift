//
//  Config+CoreDataProperties.swift
//  
//
//  Created by Paurush on 5/18/18.
//
//

import Foundation
import CoreData


extension Config {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Config> {
        return NSFetchRequest<Config>(entityName: "Config")
    }

    @NSManaged public var configinfo: String?

}
