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
    /**
     This method is used to save the RCCD file data into the core Data or database.
     
     - Parameter json: The contents of user.ini file in the json format .
     - Parameter aImageData: The provider icon in the Data format.
     */
    class func saveToDatabase(withConfig json: String, aImageData: Data?) {
        //object for appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
       
        //getting the context object for the database.
        let context = appDelegate.persistentContainer.viewContext
        
        //checks wheather the rccd file is already in the database or not.
        if alreadyInDatabase(key: json) {
            
            // Show alert already in database, if the file already exists.
            DispatchQueue.main.async {
                Utilities.showAlert(message: "RCCD_already_Imported".localized(KTLocalLang), owner: (appDelegate.window?.rootViewController)!)
            }
        }
        else {
            //if the file is not avalaible in the database.
            
            //creating the config entity.
            let entity = NSEntityDescription.entity(forEntityName: "Config", in: context)
            
            //Gets the config object from the database with the above entity.
            let newConfig = NSManagedObject(entity: entity!, insertInto: context) as? Config
            if let _newConfig = newConfig {
                
                //sets the configInfo with the json parameter.
                _newConfig.configinfo = json
                
                if let imageData = aImageData {
                   
                    //sets the image Data with the parameter aImageData.
                    _newConfig.imageData = imageData
                }
                //the context is saved with the contents of the imported RCCD file.
                appDelegate.saveContext()
               
                DispatchQueue.main.async {
                   
                    //Show alert, when the RCCD is successfully imported.
                    Utilities.showAlert(message: "RCCD_succesfully_imported".localized(KTLocalLang), owner: (appDelegate.window?.rootViewController)!)
                }
            }
        }
    }
    
    /**
     This method checks wheather there is any value corresponding to a parameter key in the database.
     
     - Parameter key: The key for which the value needs to be checked, in string type.
     
     - Returns : A bool value, corresponding to the avalaiblity of the data in the database for the key.
     */
    class func alreadyInDatabase(key: String) -> Bool {
        //Object for appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //gets the context of the database.
        let context = appDelegate.persistentContainer.viewContext
        
        //variable indicating the presence of key in the database, default set to false.
        var keyInDB = false
        
        //create the fetch request from the config entity.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request.
            let result = try context.fetch(request) as? [Config]
            if let _result = result {
                
                //iterating through the result obtained.
                for data in _result {
                    
                    //gets the key value from the config entity data.
                    let tempConfig = data.value(forKey: "configinfo") as? String
                    
                    //if the config key equals to the parameter key, then the database already have a value corresponding to that key.
                    if tempConfig == key && tempConfig != nil {
                        
                        //sets the variable to true, indicating the presence of the key in the database.
                        keyInDB = true
                        break
                    }
                }
            }
        } catch {
            print("Failed to check the key in the database.")
        }
        
        return keyInDB
    }
    
    /**
     This method is used to fetch all the services present inside the database.
     
     - Returns : An array of UserModel corresponding to different services and their providers.
     */
    class func getServicesData() -> [UserModel] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //initializing a array variable of type UserModel. To store all the services data.
        var configDataArr = [UserModel]()
        
        //creates a request to fetch the data from the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        
        request.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an config array type.
            let result = try context.fetch(request) as? [Config]
            if let _result = result {
                //iterating all the results.
                for data in _result {
                    
                    //gets the json data, type string.
                    let tempConfig = data.value(forKey: "configinfo") as? String
                    
                    //gets the image icon data, type Data.
                    let imageData = data.value(forKey: "imageData") as? Data
                    
                    // Convert To data
                    if let configStr = tempConfig {
                        
                        //encoding the json string.
                        let data1 = configStr.data(using: .utf8, allowLossyConversion: false)
                        if let _data = data1 {
                            var configJson: UserModel?
                            do {
                                //decoding/deserializing the json data into the UserModel type.
                                configJson = try JSONDecoder().decode(UserModel.self, from: _data)
                               
                                //sets the provider image logo with the imageData from Database.
                                configJson?.Providers[0].imageLogo = imageData
                            }
                            catch (let error as NSError) {
                                print("Json decoding failed...... " + error.description)
                            }
                            //checks that there is some value in the data.
                            if let tempConfigJson = configJson {
                                //appending the data into the array.
                                configDataArr.append(tempConfigJson)
                            } else {
                                // Invalid RCCD Parser
                            }
                        } else {
                            //Invalid Data Retrieved.
                        }
                        
                    }
                }
            }
        } catch {
            print("Failed")
        }
        
        return configDataArr
    }
    
    /**
     This method is used to delete all the data present in the database.
     
     This will delete all the services and rccd files present inside the database or app and will reset the application into its default state.
     */
    class func deleteAllData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates a request to fetch the contents of the database.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Config")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result from the request.
            let result = try context.fetch(request) as? [Config]
            
            //iterating through the array of results.
            if let _result = result {
                for data in _result {
                    //deleting all the data present in the result array.
                    context.delete(data)
                }
            }
            //saves the database context after deleting all the data form it.
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
}

// For User Handling.
class UserDetailsHandler {
    
    /**
     This method is used to save the username corresponding to a Service which user enters inorder to download the certificate initially. This is done, so that whenever the user selects a service , username textfield will get prepopulated with the last username entered by the user.
     
     - Parameter username: username entered by the user inorder to use the service.
     - Parameter services: service name for which the username is used.
    */
    class func saveUsernameAndServices(username: String, services: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //deletes the previous value, inorder to save the latest value.
        deleteValueIfPresent(service: services)
        
        //creates an user entity.
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        if let _entity = entity {
            //gets the value from the entity, in User Type.
            let newConfig = NSManagedObject(entity: _entity, insertInto: context) as? User
            if let _newConfig = newConfig {
                
                //sets the service field with the services parameter.
                _newConfig.service = services
                
                //sets the username field with the username parameter.
                _newConfig.username = username
            }
        }
        //saves the context of the database after updating the values.
        appDelegate.saveContext()
    }
    
    /**
     This method is used to delete the database entry of that service which already exists in the database.
     
     - Parameter service: the service name for which the database entry have to be deleted.
     */
    class func deleteValueIfPresent(service: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates a fetch request for the user entity
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("result was invalid.")
                return
            }
            //iterating the result array.
            for data in result {
                //gets the service name from the result data.
                let tempService = data.service
                
                //if the services mathches.
                if tempService == service {
                    //deletes the data for that service from the database.
                    context.delete(data)
                }
            }
            
            //updates the database context after deleting the data.
            appDelegate.saveContext()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    /**
     This method is used to get the username corresponding to a service, with which the user have previously logged in.
     
     - Parameter service: The service name for which the username is required.
     
     - Returns : The username saved for that service, in String.
     */
    class func getUsername(for service: String) -> String? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates the request to fetch the user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //gets the result for the request, an User array.
            guard let result = try context.fetch(fetchReq) as? [User] else {
                print("invalid result found.")
                return nil
            }
            
            //iterating through the result array.
            for data in result {
                let tempService = data.service
                
                //if the service matches.
                if service == tempService {
                    
                    //returns the username corresponding to the service.
                    return data.username
                }
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /*
     * This method is used to get the last input values of the user.
     - Returns : The User model, with the last entered values by the user.
    */
    class func getLastSavedEntry() -> User? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates the requst for user entity.
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        fetchReq.returnsObjectsAsFaults = false
        do {
            //validates the result obtained.
            guard let result = try context.fetch(fetchReq) as? [User], result.count > 0 else {
                print("invalid result.")
                return nil
            }
            //returns the last value of the result array.
            return result.last
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    /**
     This method is used to delete all the data corresponding to the user entity.
     All the data corresponding to the user values, will be deleted , and the application will be reset to its default state.
     */
    class func deleteAllData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //creates the request to fetch the user entity
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        do {
            //gets the result of the request, an User array.
            guard let result = try context.fetch(request) as? [User] else {
                print("invalid result found.")
                return
            }
            //iterating the result array.
            for data in result {
                //deletes all the elements of the result array from the database.
                context.delete(data)
            }
            
            //updates the database after deleting all the data.
            appDelegate.saveContext()
        } catch {
            print("Failed")
        }
    }
}
