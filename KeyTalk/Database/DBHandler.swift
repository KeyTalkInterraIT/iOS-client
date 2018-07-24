//
//  DBHandler.swift
//  KeyTalk
//
//  Created by Paurush on 5/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// For RCCD
class DBHandler {
    
    class func saveToDatabase(withConfig json: String, aImageData: Data?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if alreadyInDatabase(key: json) {
            // Show alert already in database
            DispatchQueue.main.async {
                Utilities.showAlert(message: "RCCD file already been imported.", owner: (appDelegate.window?.rootViewController)!)
            }
        }
        else {
            let entity = NSEntityDescription.entity(forEntityName: "Config", in: context)
            let newConfig = NSManagedObject(entity: entity!, insertInto: context) as! Config
            newConfig.configinfo = json
            if let imageData = aImageData {
                newConfig.imageData = imageData
            }
            appDelegate.saveContext()
            DispatchQueue.main.async {
                Utilities.showAlert(message: "RCCD file successfully imported.", owner: (appDelegate.window?.rootViewController)!)
            }
        }
    }
    
    class func alreadyInDatabase(key: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var keyInDB = false
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Config]
            for data in result {
                let tempConfig = data.value(forKey: "configinfo") as! String
                if tempConfig == key {
                    keyInDB = true
                    break
                }
            }
            
        } catch {
            print("Failed")
        }
        
        return keyInDB
    }
    
    class func getServicesData() -> [UserModel] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var configData = [UserModel]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Config]
            for data in result {
                let tempConfig = data.value(forKey: "configinfo") as? String
                let imageData = data.value(forKey: "imageData") as? Data

                // Convert To data
                if let configStr = tempConfig {
                    let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                    var configJson: UserModel?
                    do {
                        configJson = try JSONDecoder().decode(UserModel.self, from: data1!)
                        configJson?.Providers[0].imageLogo = imageData
                    }
                    catch (let error as NSError) {
                        print("Json decoding failed...... " + error.description)
                    }
                    if let tempConfigJson = configJson {
                        configData.append(tempConfigJson)
                    }
                    else {
                        // Invalid RCCD Parser
                    }
                }
            }
            
        } catch {
            print("Failed")
        }
        
        return configData
    }
    
    class func deleteAllData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [Config]
            for data in result {
                context.delete(data)
            }
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
}

class UserDetailsHandler {
    
    class func saveUsernameAndServices(username: String, services: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        deleteValueIfPresent(service: services)
        
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let newConfig = NSManagedObject(entity: entity!, insertInto: context) as! User
        newConfig.service = services
        newConfig.username = username
        appDelegate.saveContext()
    }
    
    class func deleteValueIfPresent(service: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
       // fetchReq.predicate = NSPredicate(format: "service = %@", service)
        fetchReq.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(fetchReq) as! [User]
            for data in result {
                let tempService = data.service
                if tempService == service {
                    context.delete(data)
                }
            }
            appDelegate.saveContext()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    class func getUsername(for service: String) -> String? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //fetchReq.predicate = NSPredicate(format: "service = %@", service)
        fetchReq.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(fetchReq) as! [User]
            for data in result {
                let tempService = data.service
                if service == tempService {
                    return data.username
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    class func getLastSavedEntry() -> User? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //fetchReq.predicate = NSPredicate(format: "service = %@", service)
        fetchReq.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(fetchReq) as! [User]
            if result.count > 0 {
                return result.last
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    class func deleteAllData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request) as! [User]
            for data in result {
                context.delete(data)
            }
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
}
