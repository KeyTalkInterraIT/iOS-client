//
//  LogFile.swift
//  KeyTalk
//
//  Created by Paurush on 6/6/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Log {
    
    /**
     This method is used to save the log json into the database.
     
     - Parameter json: the json string needs to be saved.
    */
    class func saveToDatabase(withConfig json: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Retrieves the count of the log data, as max count can be 20.
        if getLogData().count == 20 {
            //If the count reaches the max value, then deletes the entry from the last or the oldest entry.
            deleteFirstEntry()
        }
        
        //creates a fetch request for the log entity
        let entity = NSEntityDescription.entity(forEntityName: "LogData", in: context)
        
        //gets the result from the request, as LogData.
        guard let newConfig = NSManagedObject(entity: entity!, insertInto: context) as? LogData else{
            print("invalid result.")
            return
        }
        
        //saves the logData field with the json value.
        newConfig.logData = json
        
        //saves the updated context.
        appDelegate.saveContext()
    }
    
    /**
     This method is used to get the log data from the database.
     
     - Returns : An array of type LogData, corresponding the log data of the app.
     */
    class func getLogData() -> [LogData] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //initiates an array of LogData type, to store values from the database.
        var logData = [LogData]()
        
        //creates a request to fetch the log entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, as an array of LogData type.
            guard let result = try context.fetch(request) as? [LogData] else {
                print("invalid result.")
                return logData
            }
            //sets the variable with the result array.
            logData = result
        } catch {
            print("Failed")
        }
        return logData
    }
    
    /**
     This method is used to delete all the data from the log table in the database.
     All the information of the log file will be deleted.
     */
    class func deleteLogData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates a request to fetch the lop entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result of the reuqest , an array of type LogData.
            guard let result = try context.fetch(request) as? [LogData] else {
                print("invalid result.")
                return
            }
            
            //iterating through the result array.
            for data in result {
                //deleted every element of the array from the database.
                context.delete(data)
            }
            
            //saves the updated context.
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
    
    /**
     This method is used to delete the first entry of the log Data, i.e The oldest entry in the table will get deleted.
    */
    class func deleteFirstEntry() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creating a fetch request for the log entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result of the request, as an array of LogData.
            guard let result = try context.fetch(request) as? [LogData] , result.count > 0 else {
                print("invalid result.")
                return
            }
            
            //deletes the first index of the result array, i.e the oldest entry.
            context.delete(result[0])
            
            //saves the updated context.
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
    
    /**
        This method generates the app log in the string format.
     
     - Returns : A string with the app log data.
     */
    class func queryLog() -> String {
        //gets the log data.
        let data = getLogData()
        var queryStr = ""
        //iterating through the log Data array.
        for result in data {
            guard let tempString = result.value(forKey: "logData") as? String else {
                print("invalid string")
                return queryStr
            }
            //appending with the query string.
            queryStr = queryStr + "\n" + tempString
        }
        return queryStr
    }
    
}
