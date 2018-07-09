//
//  ServerDefines.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit

public enum URLs: Int {
    case hello
    case handshake
    case authReq
    case authentication
    case certificate
}

public enum AuthResult: String {
    case ok = "OK"
    case delayed = "DELAY"
    case locked = "LOCKED"
    case expired = "EXPIRED"
    case challenge = "CHALLENGE"
}

//https://192.168.129.122
var serverUrl = ""
var dataCert = Data()
let rcdpProtocol = "/rcdp/2.2.0"

let HELLO_URL = "/hello"
let HANDSHAKE_URL = "/handshake"
let AUTH_REQUIREMENTS_URL = "/auth-requirements"
let AUTHENTICATION_URL = "/authentication"
let CERTIFICATE_URL = "/cert?format=P12&include-chain=True&out-of-band=True"//PEM&include-chain=True"
let HTTP_METHOD_POST = "POST"

let DELAY = "DELAY"
let LOCKED = "LOCKED"
let EXPIRED = "EXPIRED"

class Server {
    
    class func getUrl(type: URLs) -> URL {
        var urlStr = ""
        switch type {
        case .hello:
             urlStr = serverUrl + rcdpProtocol + HELLO_URL
            break
        case .handshake:
             urlStr = serverUrl + rcdpProtocol + HANDSHAKE_URL + "?caller-utc=\(getISO8601DateFormat())"
            break
        case .authReq:
            urlStr = serverUrl + rcdpProtocol + AUTH_REQUIREMENTS_URL+"?service=\(serviceName)"
            break
        case .authentication:
            urlStr = serverUrl + rcdpProtocol + AUTHENTICATION_URL + authentication()
            break
        case .certificate:
            urlStr = serverUrl + rcdpProtocol + CERTIFICATE_URL
            break
        default:
            print("Encounter unidentified url type")
        }
        return URL.init(string: urlStr)!
    }
    
    class func authentication() -> String {
        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
        let hwsig = "CS-" + encodedHwsig
        let tempStr = "?service=\(serviceName)&caller-hw-description=\(UIDevice.current.modelName() + "," + UIDevice.current.name)&USERID=\(username)&PASSWD=\(password)&HWSIG=\(hwsig.uppercased())"
        
        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    class private func getISO8601DateFormat() -> String {
        let dateFormatter = DateFormatter()
        let timeZone = TimeZone.init(identifier: "GMT")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'"
        
        let iso8601String = dateFormatter.string(from: Date())
        print("FormatISO8601String::\(iso8601String)")
        return iso8601String.replacingOccurrences(of: ":", with: "%3A")
    }
}
