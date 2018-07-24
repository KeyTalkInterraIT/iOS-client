//
//  HWSIGGenerator.swift
//  KeyTalk
//
//  Created by Paurush on 6/6/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit
import UIDevice_Hardware
import CoreMotion

public enum Component_ID: Int {
    // While parsing we check Name <= component < error_code to validate
    // the HwSig formula. Keep these in range or adjust isValidHwSigComponent
    // in HwSignature.m and don't forget to update the unit tests.
    
    case Predefined = 0         // Shared value between platforms.
    
    // range 1-100 reserved for Windows Desktop Client.
    
    case error_code = 100       // parse error indicator intentionally outside our range (i.e. ignore)
    case Name = 101             // The name identifying the device keep first
    case SystemName = 102       // Name of the Operating System
    //SystemVersion             // OS version too unstable for Hw Signature
    case Model = 103            // Model of the device
    case LocalizedModel = 104   // Localized string of model.
    case UDID = 105             // Unique device Identifier deprecated in iOS 5
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
    case TotalMemory = 112      //
    // UserMemory
    // TotalDiskSpace       // Not a constant (O_0 ???) in simulator. @todo determine if constant on real device or just inaccurate.
    // FreeDiskSpace        // Unstable.
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
    
    class func isValidHwSigComponent(_ i: Component_ID) -> Bool {
        return (i == Component_ID.Predefined) || (UInt8(Component_ID.error_code.rawValue) < UInt8(i.rawValue) && UInt8(i.rawValue) < UInt8(Component_ID.sentinel.rawValue))
    }
    
    class func shouldIgnoreHwSigComponent(_ i: Component_ID) -> Bool {
        return (i == Component_ID.error_code) || (HWSIG_RANGE_END < i.rawValue) || ((i != Component_ID.Predefined) && (i.rawValue < HWSIG_RANGE_START))
    }
    
    class func getComponent(_ componentID: Component_ID) -> String? {
        return self.getComponent(componentID, from: UIDevice.current)
    }
    
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
        case .UDID:
            return KMOpenUDID.value()
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
            return UUID().uuidString
        case .error_code: /*KMLogWarning(@"Tried to fetch hardware signature component for 'error_code'");*/ return nil;
        case .sentinel: /*KMLogWarning(@"Tried to fetch hardware signature component for 'sentinel'");*/ return nil;
        }
    }
    
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
        case .UDID:
            return "UDID"
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
    
    class func systemInfo() -> String {
        let device = UIDevice.current
        let formatString = """
        System name: %@\n\
        System version: %@\n\
        Platform: %@\n\
        Hardware model: %@\n\
        Memory (user/total): %d/%d\n\
        Diskspace (free/total): %d/%d\n\
        CPU frequency: %d, BUS frequency: %d\n
        """
        return String(format: formatString, device.systemName, device.systemVersion, device.modelName(), device.hwmodel(), "\(UInt(device.userMemory()))", "\(UInt(device.totalMemory()))", "\(device.freeDiskSpace())", "\(device.totalDiskSpace())", "\(UInt(device.cpuFrequency()))", "\(UInt(device.busFrequency()))")
    }
}

class HWSIGCalc {
    
    class func saveHWSIGFormula(formula: String) {
        UserDefaults.standard.set(formula, forKey: "hwsigformula")
    }
    
    private class func parseHWSIGFormula(formula: String) -> [NSNumber] {
        let tokens = formula.components(separatedBy: ",")
        let whites = CharacterSet.whitespacesAndNewlines
        let formatter = NumberFormatter()
        
        var arr = [NSNumber]()
        
        for s in tokens {
            let x = formatter.number(from: s.trimmingCharacters(in: whites))
            var value = Component_ID.error_code.rawValue
            if let x = x {
                value = x.intValue
            }
            let id = Component_ID(rawValue: value)
            if let id = id {
                if !HWSIGCheck.shouldIgnoreHwSigComponent(id) {
                    arr.append(NSNumber.init(value: HWSIGCheck.isValidHwSigComponent(id) ? id.rawValue : Component_ID.Predefined.rawValue))
                }
            }
        }
        if arr.count == 0 {
            arr.append(NSNumber.init(value: Component_ID.Predefined.rawValue))
        }
        return arr
    }
    
    private class func getHWSIGFormula() -> String {
        var formula = ""
        let str = UserDefaults.standard.value(forKey: "hwsigformula") as? String
        if let str = str {
            formula = str
        }
        return formula
    }
    
    class func calcHwSignature() -> String {
        let actualFormula = parseHWSIGFormula(formula: getHWSIGFormula())
        var components = [String]()
        for number in actualFormula {
            let compIDInt = number.intValue
            let compIDType = Component_ID.init(rawValue: compIDInt)
            if let compIDType = compIDType {
                let componentName = HWSIGCheck.getComponentName(compIDType)
                let componentValue = HWSIGCheck.getComponent(compIDType)
                print("Component name and value", componentName!, componentValue!)
                components.append(componentValue!)
            }
        }
        //let signatureData = components.joined(separator: "").data(using: .utf8)
        let hwSigStr = components.joined(separator: "")
        return hwSigStr
    }
    
}

