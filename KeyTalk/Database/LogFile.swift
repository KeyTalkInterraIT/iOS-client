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
    
    /* static let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
     static let fileManager = FileManager.default
     static let directoryPath = docDir + "/Log"
     static let filePath = directoryPath + "/log.txt"
     
     class func saveDataToLogFile(aLogData: String) {
     let isDirectory = createDirectoryOrPath(path: directoryPath, directory: true)
     let isFile = createDirectoryOrPath(path: filePath, directory: false)
     
     if isDirectory && isFile {
     let contents = fileManager.contents(atPath: filePath)
     if let contents = contents {
     let strLog = String.init(data: contents, encoding: .utf8)
     if var strLog = strLog {
     strLog = strLog + aLogData
     let data = strLog.data(using: .utf8)
     let url = URL.init(string: "file://" + filePath)
     if let data = data, let url = url {
     do {
     try data.write(to: url)
     }
     catch let error {
     print(error.localizedDescription)
     }
     }
     }
     }
     }
     }
     
     private class func createDirectoryOrPath(path: String, directory: Bool) -> Bool {
     var createdSuccessfully = false
     if !alreadyExist(path: path) {
     do {
     if directory {
     try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: [:])
     }
     else {
     fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
     }
     }
     catch let error {
     createdSuccessfully = false
     print(error.localizedDescription)
     }
     createdSuccessfully = true
     }
     else {
     createdSuccessfully = true
     }
     return createdSuccessfully
     }
     
     private class func alreadyExist(path: String) -> Bool {
     var exist = false
     if fileManager.fileExists(atPath: path) {
     exist = true
     }
     return exist
     }
     
     class func getURlForLogFile() -> String {
     return filePath
     } */
    
    
    class func saveToDatabase(withConfig json: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if getLogData().count == 20 {
            deleteFirstEntry()
        }
        let entity = NSEntityDescription.entity(forEntityName: "LogData", in: context)
        let newConfig = NSManagedObject(entity: entity!, insertInto: context) as! LogData
        newConfig.logData = json
        appDelegate.saveContext()
    }

    class func getLogData() -> [LogData] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var logData = [LogData]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [LogData]
            logData = result
        } catch {
            print("Failed")
        }
        return logData
    }
    
    class func deleteLogData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [LogData]
            for data in result {
                context.delete(data)
            }
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
    
    class func deleteFirstEntry() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LogData")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [LogData]
            if result.count > 0 {
                context.delete(result[0])
            }
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
    
    class func queryLog() -> String {
        let data = getLogData()
        var queryStr = ""
        for result in data {
            let tempString = result.value(forKey: "logData") as! String
            queryStr = queryStr + "\n" + tempString
        }
        return queryStr
    }
    
}
