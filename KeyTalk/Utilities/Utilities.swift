//
//  Utilities.swift
//  KeyTalk
//
//  Created by Paurush on 5/16/18.
//

import Foundation
import Zip
import CoreData

//This is the helper class, with various modules that can be utilized throughout the application.
class Utilities {
    
    /**
     This method is used to unzip the RCCD file which is located within the app, at a particular location.
     The unzipping is done to retrive the contents of the RCCD file and then the parsing is done and finally all the data is saved in the database.
     
     - Parameter url: The url at which the rccd file is kept.
     
     It sends the callback to the successhandler , indicating that the file was successfully unzipped or not.
     */
    class func unzipRCCDFile(url: URL, completionHandler:@escaping (_ success: Bool) -> Void) {
        
        do {
            //gets the document directory path.
            let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let fileManager = FileManager.default
            
            //add the component in the directory path.
            let filePath = documentsDirectory.appendingPathComponent("/ParsingRCCD")
            
            //checks, if file already exists.
            if fileManager.fileExists(atPath: filePath.path) {
                do {
                    //if exists, then remove it.
                    try fileManager.removeItem(at: filePath)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
            do {
                //creating a seperate directory inorder to save the file.
                try fileManager.createDirectory(at: filePath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error {
                print(error.localizedDescription)
            }
            
            //unzippping is done by picking the file from the url and the unzipped file is saved at the destination path named 'filepath'.
            try Zip.unzipFile(url, destination: filePath, overwrite: true, password: "", progress: { (progress) -> () in
                print(progress)
                //the process value indicates the completion of the unzipping process.
                if (progress == 1.0)
                    //this means that the file is completeley unzipped.
                {
                    //adding components at the destination path.
                    let defaultPath = filePath.appendingPathComponent("content")
                    let iniPath = defaultPath.appendingPathComponent("user.ini")
                    let imagePath = defaultPath.appendingPathComponent("logo.png")
                    
                    //retriving the icon data of the provider from the rccd file.
                    var imageData: Data? = nil
                    do {
                        //gets the contents of the user.ini file.
                        let data: Data? = try Data.init(contentsOf: iniPath)
                        if fileManager.fileExists(atPath: imagePath.path) {
                            //gets the image data of the provider icon, form the rccd file.
                            imageData = try Data.init(contentsOf: imagePath)
                        }
                        
                        if let _data = data {
                            //converts the contents of the user.ini into a string for parsing it.
                            guard let tempStr = String.init(data: _data, encoding: .utf8) else {
                                completionHandler(false)
                                return
                            }
                            
                            //gets the json converted string of the user.ini file.
                            let json = INIParser.parseIni(aIniString: tempStr)
                            if json.count > 0 {
                                if let imageData = imageData {
                                    //sets the image Data in the database.
                                    DBHandler.saveToDatabase(withConfig: json, aImageData: imageData)
                                }
                                else {
                                    //sets the empty image Data in the database.
                                    DBHandler.saveToDatabase(withConfig: json, aImageData: nil)
                                }
                                
                                //indicates that the unzip process is successfully completed
                                completionHandler(true)
                            }
                            else {
                                //indicates that the unzip process failed.
                                completionHandler(false)
                            }
                        }
                    }
                    catch (let error as NSError) {
                        completionHandler(false)
                        print(error.description)
                    }
                }
            })
        }
        catch (let error as NSError) {
            print("Something went wrong")
            print(error.description)
        }
    }
    
    /**
     This method is used to present a alert pop up view with a message.
     - Parameter title: The title of the alert view, set to Keytalk.
     - Parameter message: The message to be displayed in the alert.
     - Parameter owner: The owner of the view, or the Controller on which this view is to be presented.
     */
    class func showAlert(with title:String? = "KeyTalk", message: String, owner: UIViewController) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //OK action is added.
        let action = UIAlertAction(title: "ok_string".localized(KTLocalLang), style: .destructive, handler: nil)
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    /**
     This method is used to present a alert pop up view with a message and by clicking 'OK' a particular action is taken place as the completionHandler is called.
     - Parameter title: The title of the alert view, set to Keytalk.
     - Parameter message: The message to be displayed in the alert.
     - Parameter owner: The owner of the view, or the Controller on which this view is to be presented.
     */
    class func showAlert(with title:String? = "KeyTalk", message: String, owner: UIViewController, completionHandler:@escaping (_ success: Bool) -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok_string".localized(KTLocalLang), style: .destructive) { (alert) in
            completionHandler(true)
        }
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    /**
     This method is used to present a alert pop up view with a message and by clicking 'OK' or 'Cancel' a particular action is taken place as the completionHandler is called.
     - Parameter title: The title of the alert view, set to Keytalk.
     - Parameter message: The message to be displayed in the alert.
     - Parameter owner: The owner of the view, or the Controller on which this view is to be presented.
     */
    class func showAlertWithCancel(with title:String? = "KeyTalk", message: String, owner: UIViewController, completionHandler:@escaping (_ success: Bool) -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok_string".localized(KTLocalLang), style: .default) { (alert) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel_string".localized(KTLocalLang), style: .destructive) { (alert) in
            completionHandler(false)
        }
        controller.addAction(cancelAction)
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    /**
     This method is used to generate a valid Url compatible for server communication.
     - Parameters urlStr: the raw URl which needs to be validated.
     - Returns : A valid URl for server communication.
     */
    class func returnValidServerUrl(urlStr: String) -> String {
        var tempStr = urlStr
        if (!tempStr.contains("https")) {
            tempStr = "https://" + tempStr
        }
        return tempStr
    }
    
    /**
     This methos is used to reset all the global values equal to ther initial value.
     */
    class func resetGlobalMemberVariables() {
        username = ""
        password = ""
        keytalkCookie = ""
        serviceName = ""
        dataCert = Data()
        serverUrl = ""
    }
    
    /**
     This method is used to calculate the height of the drop down table / menu .
     - Parameter yOfTable: point in the y axis, from which the table starts.
     - Returns: The height of the table, which will be visible to the user.
     */
    class func calculateHeightForTable(yOfTable: CGFloat) -> CGFloat {
        var height:CGFloat = 0.0
        height = screenHeight - keyBoardHeight - yOfTable - 5
        return height
    }
    
    /**
     This method saves tha app log data in the database.
     */
    class func saveToLogFile(aStr: String) {
        Log.saveToDatabase(withConfig: aStr)
    }
    
    
    class func provideStringForResponse(response: HTTPURLResponse) -> String {
        var responseStr = "\("response_status_string".localized(KTLocalLang)) \(response.statusCode)"
        for (key, value) in response.allHeaderFields {
            let keyStr = key as? String
            let valueStr = value as? String
            if let key1 = keyStr, let value1 = valueStr {
                responseStr = responseStr + "\n" + key1 + ": " + value1
            }
        }
        return responseStr
    }
    
    /**
     This method is used to get the version number of the app.
     */
    class func getVersionNumber() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return version
    }
    
    /**
     This method is used to get the build number of the app.
     */
    class func getBuildNumber() -> String {
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return build
    }
    
    /**
     This method is used to delete all the data from the database, and set the app at its initial state(i.e reset the app).
     */
    class func deleteAllDataFromDB() {
        //delete all the data related to the rccd and services from the database..
        DBHandler.deleteAllData()
        
        //deletes all the log data from the database.
        Log.deleteLogData()
        
        //delete all the data related to the users and services from the database..
        UserDetailsHandler.deleteAllData()
    }
    
    /**
     This method is used to adjust or render the screen for iphoneX device.
     - Parameter view: The view which is needed to be rendered according to the device.
     */
    class func changeViewAccToXDevices(view: UIView) {
        for view in view.subviews {
            if (view.tag != 500) {
                var frame = view.frame
                frame.origin.y += 14
                view.frame = frame
            }
        }
    }
    
    /**
     This method is used to encode the raw string into the encrypted string using UTF8 encoding.
     it is basically used to encode the hardware signature, which is send to the server for the authentication in the encoded form.
     
     - Parameter securityString: the raw string which needs to be encoded.
     - Returns: An encrypted string,encrypted using UTF8 encoding.
     */
    class func sha256(securityString : String) -> String {
        let data = securityString.data(using: .utf8)! as NSData
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in hash {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
    
    /*
     This method is used to check if the system language is compatible to the application for localization.
     Also checks if language is already selected by user or not.
     */
    class func getLocalCode(){
        let code = NSLocale.current.languageCode ?? "en"
        switch code {
        case "en":
            KTLocalLang = "en"
        case "dr":
            KTLocalLang = "dr"
        case "fr":
            KTLocalLang = "fr"
        case "nl":
            KTLocalLang = "nl"
        default:
            KTLocalLang = "en"
        }
        //checks if language is already selected by user or not
        if let x = UserDefaults.standard.value(forKey: "KTCurrentLanguageKey"){
            KTLocalLang = x as! String
        }
    }
    
    /**
     This method is used to check if the system language is compatible to the application for localization.
     Also checks if language is already selected by user or not.
     
     - Parameter code: language code which is needs to be stored with the associated Key.
     */
    class func saveLocalCode(language code: String){
        UserDefaults.standard.set(code, forKey: "KTCurrentLanguageKey")
        UserDefaults.standard.synchronize()
    }
}
