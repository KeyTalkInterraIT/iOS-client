//
//  HWSIGGenerator.swift
//  KeyTalk
//
//  Created by Paurush on 6/6/18.
//

import Foundation
import UIKit
import UIDevice_Hardware
import CoreMotion

public enum Component_ID: Int {
    // While parsing we check Name <= component < error_code to validate
    // the HwSig formula. Keep these in range or adjust isValidHwSigComponent
    
    case Predefined = 0         // Shared value between platforms.
    
    // range 1-100 reserved for Windows Desktop Client.
    
    case error_code = 100       // parse error indicator intentionally outside our range (i.e. ignore)
    case Name = 101             // The name identifying the device keep first
    case SystemName = 102       // Name of the Operating System
    //SystemVersion             // OS version too unstable for Hw Signature
    case Model = 103            // Model of the device
    case LocalizedModel = 104   // Localized string of model.
//    case UDID = 105             // Unique device Identifier deprecated in iOS 5
    // We use the (software) OpenUDID here instead.
    case BundleIdentifier = 106 // Software bundle ID (client App ID)
    // userInterfaceIdiom   // (is this one at all useful?)
    
    // Values provided by UIDevice-Hardware library
    case Platform = 107         // Platform identification string
    case HwModel = 108          //
    //PlatformType         // derived from Platform
    case PlatformString = 109   // derived from Platform "friendly name"
    case CPU_Frequency = 110    // @todo Actual or max? Does it change on iPhone/iPad?
    case BUS_Frequency = 111    // @todo As above
    case TotalMemory = 112      /*
    // UserMemory
    // TotalDiskSpace       // Not a constant (O_0 ???) in simulator. @todo determine if constant on real device or just inaccurate.
    // FreeDiskSpace        // Unstable. */
    case MacAddress = 113       // MAC address of primary interface
    // @todo handle case .where this interface is disabled.
    
    // Available sensors
    case Gyro = 114             // Gyro available?
    case Magnetometer = 115     // Magnetometer available?
    case Accelerometer = 116    // Accelerometer available?
    case Devicemotion = 117     // DeviceMotion available?
    case KeytalkUUID = 199     // RandomNumber Keytalk
    case sentinel = 200          // end of defined ID markers keep as last.
    
    // These will lead to an appstore reject:
    // they rely on IOKit which is semi-public (i.e. public but non-documented)
    // - imei
    // - serialnumber
}

let HWSIG_PREDEFINED = "000000000000"
let HWSIG_RANGE_START = 101
let HWSIG_RANGE_END = 200

class HWSIGCheck {
    
    /**
     This method checks wheather the given component of the hardware signature is valid or not.
     - Parameter i : the id of the hardware signature component.
     - Returns : bool value, indicating the validity of the component id.
    */
    class func isValidHwSigComponent(_ i: Component_ID) -> Bool {
        //returns true , when the component is predefined, or the component lies between the error_code and sentinel. else returns false.
        return (i == Component_ID.Predefined) || (UInt8(Component_ID.error_code.rawValue) < UInt8(i.rawValue) && UInt8(i.rawValue) < UInt8(Component_ID.sentinel.rawValue))
    }
    
    /**
     This method checks wheather the given component of the hardware signature lies in the predefined list of hardware signature components.
     - Parameter i : the id of the hardware signature component.
     - Returns : bool value, to indicate wheather to use the component or not.
     */
    class func shouldIgnoreHwSigComponent(_ i: Component_ID) -> Bool {
        //returns true, when the component id is present in the predefined list, else returns false.
        return (i == Component_ID.error_code) || (HWSIG_RANGE_END < i.rawValue) || ((i != Component_ID.Predefined) && (i.rawValue < HWSIG_RANGE_START))
    }
    
    /**
     This method is used to get the component information for the hardware signature.
     
     - Parameter componentID: The id of the component , whose information is required.
     - Returns : the information of the hardware component , in string type.
     */
    class func getComponent(_ componentID: Component_ID) -> String? {
        return self.getComponent(componentID, from: UIDevice.current)
    }
    
    /**
     This method is used to get the component information for the hardware signature.
     
     - Parameter componentID: The id of the component , whose information is required.
     - Parameter UIDevice: The device current object, from which the informations needs to be retrieved.

     - Returns : the information of the hardware component , in string type.
     */
    class func getComponent(_ componentID: Component_ID, from UIDevice: UIDevice) -> String? {
        switch componentID {
        case .Predefined:
            return HWSIG_PREDEFINED
        case .Name:
            return UIDevice.name
        case .SystemName:
            return UIDevice.systemName
        case .Model:
            return UIDevice.model
        case .LocalizedModel:
            return UIDevice.localizedModel
//        case .UDID:
//            return KMOpenUDID.value()
        case .BundleIdentifier:
            return Bundle.main.bundleIdentifier
        case .Platform:
            return UIDevice.platform()
        case .HwModel:
            return UIDevice.hwmodel()
        case .PlatformString:
            return UIDevice.modelName()
        case .CPU_Frequency:
            return "\(UInt(UIDevice.cpuFrequency()))"
        case .BUS_Frequency:
            return "\(UInt(UIDevice.busFrequency()))"
        case .TotalMemory:
            return "\(UInt(UIDevice.totalMemory()))"
        case .MacAddress:
            return "\(UInt(UIDevice.macaddress()) ?? 00)"
        case .Gyro:
            let mm = CMMotionManager()
            return mm.isGyroAvailable ? "Gyro" : "NoGyro"
        case .Magnetometer:
            let mm = CMMotionManager()
            return mm.isMagnetometerAvailable ? "Magnetometer" : "NoMagnetometer"
        case .Accelerometer:
            let mm = CMMotionManager()
            return mm.isAccelerometerAvailable ? "Accelerometer" : "NoAccelerometer"
        case .Devicemotion:
            let mm = CMMotionManager()
            return mm.isDeviceMotionAvailable ? "Devicemotion" : "NoDevicemotion"
        case .KeytalkUUID:
            return UIDevice.identifierForVendor?.uuidString
        case .error_code: /*KMLogWarning(@"Tried to fetch hardware signature component for 'error_code'");*/ return nil;
        case .sentinel: /*KMLogWarning(@"Tried to fetch hardware signature component for 'sentinel'");*/ return nil;
        }
    }
    
    /**
     This method is used to get the UDID value of the device, which is a 40 char string indicating the device UDID info.
     In this, a random number is saved in the device keychain initially, with a unique key named 'udid_key'. which will not change even when the app gets uninstalled.
     initially there will be no value corresponding to this key, so a value will be saved corresponding to that key, and after that , the same value will be assumed as the UDID for that device.
     
     - Returns : A string indicating the UDID of the device.
     */
    class func getUDID() -> String {
        //the key, for the key chain to store the UDID value.
        let udid_key = "com.interrait.keytalkinterra.udid"
        
        //check that the  key have some corresponding value in the keychain.
        let RecievedDataStringAfterSave = KTUDID.load(key: udid_key)
        if let _recievedData = RecievedDataStringAfterSave {
            //if value exists
            //converts the data value into string.
            let NSDATAtoString = KTUDID.NSDATAtoString(data: _recievedData)
            return NSDATAtoString
        } else  {
            
            //if value doesnot exists.
            
            //A random number, assumed to be the UDID of the device.
            let udid_Str = UUID().uuidString
            
            //Converting the string into the data format to be saved in the keychain.
            let string_value = KTUDID.stringToNSDATA(string: udid_Str)
            
            //saving the value in the keychain.
            KTUDID.save(key: udid_key, value: string_value as Data)
            return udid_Str
        }
    }
    
    //gettting the name of the hardware component.
    class func getComponentName(_ componentId: Component_ID) -> String? {
        switch componentId {
        case .Predefined:
            return "Predefined"
        case .Name:
            return "Name"
        case .SystemName:
            return "System name"
        case .Model:
            return "Model"
        case .LocalizedModel:
            return "Localized model"
//        case .UDID:
//            return "UDID"
        case .BundleIdentifier:
            return "Bundle identifier"
        case .Platform:
            return "Platform"
        case .PlatformString:
            return "Platform friendly name"
        case .HwModel:
            return "Hardware model"
        case .CPU_Frequency:
            return "CPU Frequency"
        case .BUS_Frequency:
            return "BUS Frequency"
        case .TotalMemory:
            return "Total memory"
        case .MacAddress: return "MAC address"
        case .Gyro: return "Gyro available"
        case .Magnetometer: return "Magnetometer available"
        case .Accelerometer: return "Accelerometer available"
        case .Devicemotion: return "Devicemotion available"
        case .KeytalkUUID: return "Random number"
        case .error_code: return nil
        case .sentinel: return nil
        }
    }
    
    //returning system information in the String format
    class func systemInfo() -> String {
        let device = UIDevice.current
        let System_name = "System_name".localized(KTLocalLang)
        let System_version = "System_version".localized(KTLocalLang)
        let Platform_string = "Platform_string".localized(KTLocalLang)
        let Hardware_model = "Hardware_model".localized(KTLocalLang)
        let Memory_string = "Memory_string".localized(KTLocalLang)
        let Diskspace_string = "Diskspace_string".localized(KTLocalLang)
        let CPU_frequency = "CPU_frequency".localized(KTLocalLang)
        let BUS_frequency = "Diskspace_string".localized(KTLocalLang)
        let formatString = """
        \(System_name) %@\n\
        \(System_version) %@\n\
        \(Platform_string) %@\n\
        \(Hardware_model) %@\n\
        \(Memory_string) %d/%d\n\
        \(Diskspace_string) %d/%d\n\
        \(CPU_frequency) %d, \(BUS_frequency) %d\n
        """
        return String(format: formatString, device.systemName, device.systemVersion, device.modelName(), device.hwmodel(), "\(UInt(device.userMemory()))", "\(UInt(device.totalMemory()))", "\(device.freeDiskSpace())", "\(device.totalDiskSpace())", "\(UInt(device.cpuFrequency()))", "\(UInt(device.busFrequency()))")
    }
}

class HWSIGCalc {
    
    /**
     This method save the hardware signature formula locally within the app with a unique key.
     
     - Parameter formula : the formula for the hardware signature, needed to be stored.
     */
    class func saveHWSIGFormula(formula: String) {
        UserDefaults.standard.set(formula, forKey: "hwsigformula")
    }
    
    /**
     This method is used to parse the hardware signature formula.
     
     - Parameter formula: the formula of hardware signature needed to be parsed, in string type.
     
     - Returns : An array , where each element will represent different hardware requirements.
    */
    private class func parseHWSIGFormula(formula: String) -> [NSNumber] {
        
        //the formula is seperated by comma, into an array.
        let tokens = formula.components(separatedBy: ",")
        
        //removes the white spaces and new lines.
        let whites = CharacterSet.whitespacesAndNewlines
       
        let formatter = NumberFormatter()
        
        //an array variable, used to store the different hardware requirements during parsing.
        var arr = [NSNumber]()
        
        //iterating through the token array.
        for s in tokens {
            let x = formatter.number(from: s.trimmingCharacters(in: whites))
            
            //fetching the component value corresponding to the component ID.
            var value = Component_ID.error_code.rawValue
            if let x = x {
                value = x.intValue
            }
            
            //sets the ID of the Component.
            let id = Component_ID(rawValue: value)
            if let id = id {
                //validating the hardware signature, wheather needs to be used or not.
                if !HWSIGCheck.shouldIgnoreHwSigComponent(id) {
                    //if valid,appending into an array.
                    arr.append(NSNumber.init(value: HWSIGCheck.isValidHwSigComponent(id) ? id.rawValue : Component_ID.Predefined.rawValue))
                }
            }
        }
        if arr.count == 0 {
            arr.append(NSNumber.init(value: Component_ID.Predefined.rawValue))
        }
        return arr
    }
    
    /**
     This method is used to get the locally saved hardware signature formula .
     
     - Returns : The hardware signature formula.
    */
    private class func getHWSIGFormula() -> String {
        var formula = ""
        //Retrieves the hardware signature formula from the local storage.
        let str = UserDefaults.standard.value(forKey: "hwsigformula") as? String
        if let str = str {
            //assigns the variable.
            formula = str
        }
        return formula
    }
    
    
    /**
     This method is used to calculate the hardware signature value , which is needed to be send to the server inorder to fulfill the authentication requirements.
     
     - Returns : A String containing all the hardware component information asked in the authentication requirements.
     */
    class func calcHwSignature() -> String {
        //gets the array of number after parsing the hardware signature formula, indicating the required hardware requirements.
        let actualFormula = parseHWSIGFormula(formula: getHWSIGFormula())
        var components = [String]()
        
        //iterating through the formula array.
        for number in actualFormula {
            
            let compIDInt = number.intValue
            let compIDType = Component_ID.init(rawValue: compIDInt)
            if let compIDType = compIDType {
                //sets the component name
                let componentName = HWSIGCheck.getComponentName(compIDType)
                
                //sets the component information
                let componentValue = HWSIGCheck.getComponent(compIDType)
                print("Component name and value", componentName!, componentValue!)
                
                //appends in the array
                components.append(componentValue!)
            }
        }
        //joined all the array components, with a space.
        let hwSigStr = components.joined(separator: "")
        return hwSigStr
    }
    
}

