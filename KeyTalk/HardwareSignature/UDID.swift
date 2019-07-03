//
//  UDID.swift
//  KeyTalk
//
//  Created by Anshuman Singh on 7/31/18.
//

import Foundation

class KTUDID {
    
    /**
     This method is used to save a value in the keychain corresponding to a key.
     
     - Parameter key: The key on which the value needs to be saved.
     - Parameter value: The value which needs to be saved.

     */
    class func save(key: String, value: Data) {
        
        //creates the keychain query , with all the necessary values.
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : value ] as [String : Any]
        
        //items added in the keychain.
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("item saved in keychain")
        } else {
            print("unable to save in keychain")
        }
        
    }
    
    /**
     This method is used to delete a value in the keychain corresponding to a key.
     - Parameter key: The key on which the value needs to be deleted..
     */
    class func remove(key: String) {
        //creates the keychain query , with all the necessary values.
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : load(key: key) as Any ] as [String : Any]

        // Delete any existing items, for the key.
        let status = SecItemDelete(query as CFDictionary)
        if (status != errSecSuccess) {
            print("Remove failed:")
        }
        
    }
    
    /**
     This method is used to retrieve a value in the keychain corresponding to a key.
     - Parameter key: The key on which the value needs to be retrieved.
     */
    class func load(key: String) -> NSData? {
        //creates the keychain query , with all the necessary values.
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            //gets the retrived data, for the key.
            let retrievedData:Data = (dataTypeRef as? Data)!
            return retrievedData as NSData
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
            return nil
        }
    }
    
    /**
     This method is used to convert the string type into the NSData type
     - Parameter string: which needs to be converted.
     - Returns : The converted string into the NSData type.
     */
    class func stringToNSDATA(string : String)->NSData
    {
        let _Data = (string as NSString).data(using: String.Encoding.utf8.rawValue)
        return _Data! as NSData
        
    }
    
    /**
     This method is used to convert the NSData type into the String type
     - Parameter data: which needs to be converted.
     - Returns : The converted NSData into the String type.
     */
    class func NSDATAtoString(data: NSData)->String
    {
        let returned_string : String = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return returned_string
    }
    
    /**
     This method is used to create a unique random string of 36 char.
     - Returns : A unique random string.
     */
    class func CreateUniqueID() -> String
    {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr:CFString = CFUUIDCreateString(nil, uuid)
        
        let nsTypeString = cfStr as NSString
        let swiftString:String = nsTypeString as String
        return swiftString
    }
    
}
