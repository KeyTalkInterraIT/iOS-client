//
//  LogData+CoreDataProperties.swift
//  
//
//  Created by Paurush on 6/14/18.
//
//

import Foundation
import CoreData


extension LogData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogData> {
        return NSFetchRequest<LogData>(entityName: "LogData")
    }

    @NSManaged public var logData: String?
    @NSManaged public var count: Int16

}
