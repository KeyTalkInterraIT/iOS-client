//
//  Utilities.swift
//  KeyTalk
//
//  Created by Paurush on 5/16/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import Zip
import CoreData

class Utilities {
    
    class func unzipRCCDFile(url: URL, completionHandler:@escaping (_ success: Bool) -> Void) {
        
        do {
            let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
            let fileManager = FileManager.default
            let filePath = documentsDirectory.appendingPathComponent("/ParsingRCCD")
            if fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.removeItem(at: filePath)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
            do {
                try fileManager.createDirectory(at: filePath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error {
                print(error.localizedDescription)
            }
            
            try Zip.unzipFile(url, destination: filePath, overwrite: true, password: "", progress: { (progress) -> () in
                print(progress)
                
                if (progress == 1.0) {
                    
                    let defaultPath = filePath.appendingPathComponent("content")
                    let iniPath = defaultPath.appendingPathComponent("user.ini")
                    let imagePath = defaultPath.appendingPathComponent("logo.png")
                    var imageData: Data? = nil
                    do {
                        let data: Data? = try Data.init(contentsOf: iniPath)
                        if fileManager.fileExists(atPath: imagePath.path) {
                          imageData = try Data.init(contentsOf: imagePath)
                        }
                        if data != nil {
                            let tempStr = String.init(data: data!, encoding: .utf8)
                            let json = INIParser.parseIni(aIniString: tempStr!)
                            if json.count > 0 {
                                if let imageData = imageData {
                                    DBHandler.saveToDatabase(withConfig: json, aImageData: imageData)
                                }
                                else {
                                    DBHandler.saveToDatabase(withConfig: json, aImageData: nil)
                                }
                                
                                completionHandler(true)
                            }
                            else {
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
    
    class func showAlert(with title:String? = "KeyTalk", message: String, owner: UIViewController) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive, handler: nil)
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    class func showAlert(with title:String? = "KeyTalk", message: String, owner: UIViewController, completionHandler:@escaping (_ success: Bool) -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .destructive) { (alert) in
            completionHandler(true)
        }
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    class func showAlertWithCancel(with title:String? = "KeyTalk", message: String, owner: UIViewController, completionHandler:@escaping (_ success: Bool) -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (alert) in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert) in
            completionHandler(false)
        }
        controller.addAction(cancelAction)
        controller.addAction(action)
        owner.present(controller, animated: true, completion: nil)
    }
    
    class func returnValidServerUrl(urlStr: String) -> String {
        var tempStr = urlStr
        if (!tempStr.contains("https")) {
            tempStr = "https://" + tempStr
        }
        return tempStr
    }
    
    class func resetGlobalMemberVariables() {
        username = ""
        password = ""
        keytalkCookie = ""
        serviceName = ""
        dataCert = Data()
        serverUrl = ""
    }
    
    class func calculateHeightForTable(yOfTable: CGFloat) -> CGFloat {
        var height:CGFloat = 0.0
        height = screenHeight - keyBoardHeight - yOfTable - 5
        return height
    }
    
    class func saveToLogFile(aStr: String) {
        Log.saveToDatabase(withConfig: aStr)
    }
    
    class func proivdeStringForResponse(response: HTTPURLResponse) -> String {
        var responseStr = "Status : \(response.statusCode)"
        for (key, value) in response.allHeaderFields {
            let keyStr = key as? String
            let valueStr = value as? String
            if let key1 = keyStr, let value1 = valueStr {
                responseStr = responseStr + "\n" + key1 + ": " + value1
            }
        }
        return responseStr
    }
    
    class func getVersionNumber() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        return version
    }
    
    class func getBuildNumber() -> String {
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        return build
    }
    
    class func deleteAllDataFromDB() {
        DBHandler.deleteAllData()
        Log.deleteLogData()
        UserDetailsHandler.deleteAllData()
    }
    
    class func changeViewAccToXDevices(view: UIView) {
        for view in view.subviews {
            if (view.tag != 500) {
                var frame = view.frame
                frame.origin.y += 14
                view.frame = frame
            }
        }
    }
    
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
}
