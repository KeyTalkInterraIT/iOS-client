//
//  ServerDefines.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit

//Enum for the type of URLs.
public enum URLs: Int {
    case hello
    case handshake
    case authReq
    case authentication
    case challenge
    case certificate
}

//Enum for the types of Authentication status.
public enum AuthResult: String {
    case ok = "OK"
    case delayed = "DELAY"
    case locked = "LOCKED"
    case expired = "EXPIRED"
    case challenge = "CHALLENGE"
}

//Enum for the names of the challenges
public enum ChallengeResult :String {
    case PassWordChallenge = "Password challenge"
}

//Enum for the values of the challenges.
public enum ChallengeType : String {
    case nextToken = "Please Enter the Next Code from Your Token:"
    case otp = "otp"
    case newUserDefinedPin = "Enter your new PIN of 4 to 8 digits,or <Ctrl-D> to cancel the New PIN procedure:"
    case reenterNewPin = "Please re-enter new PIN:"
    case newPinandPasscode = "Wait for the code on your card to change, then enter new PIN and TokenCode\r\n\r\nEnter PASSCODE:"
    case newSystemPushedPin = "Are you prepared to accept a new system-generated PIN [y/n]?"
}

//https://192.168.129.122
var serverUrl = ""

//variable for the data send by the server.
var dataCert = Data()

//protocol used.
let rcdpProtocol = "/rcdp/2.4.1"
var caPort = ":8443"
var port = ":4443"

//url extentions needed to communicate with the server.
let HELLO_URL = "/hello"
let HANDSHAKE_URL = "/handshake"
let AUTH_REQUIREMENTS_URL = "/auth-requirements"
let AUTHENTICATION_URL = "/authentication"
let CERTIFICATE_URL = "/cert?format=P12&include-chain=True&out-of-band=True"
let HTTP_METHOD_POST = "POST"

//auth status
let DELAY = "DELAY"
let LOCKED = "LOCKED"
let EXPIRED = "EXPIRED"

class Server {
    
    /**
     This method is used to get different types of valid URL for server communication
     
     - Parameter type: the type of server communication for which the Url is needed.
     - Returns: The URL for the communication.
     */
    class func getUrl(type: URLs) -> URL? {
        var urlStr = ""
        switch type {
        case .hello:
            urlStr = serverUrl + port + rcdpProtocol + HELLO_URL
            break
        case .handshake:
            urlStr = serverUrl + port + rcdpProtocol + HANDSHAKE_URL + "?caller-utc=\(getISO8601DateFormat())"
            break
        case .authReq:
            urlStr = serverUrl + port + rcdpProtocol + AUTH_REQUIREMENTS_URL+"?service=\(serviceName)"
            break
        case .authentication:
            urlStr = serverUrl + port + rcdpProtocol + AUTHENTICATION_URL + authentication()
            break
        case .challenge:
            urlStr = serverUrl + port + rcdpProtocol + AUTHENTICATION_URL + challengeAuthenticationURL(challenge: challengeResponseArr)
            break
        case .certificate:
            urlStr = serverUrl + port + rcdpProtocol + CERTIFICATE_URL
            break
            
        }
        return URL.init(string: urlStr)
    }
    
    /**
     This method is used to get the component information required to complete the authentication from the server.
     - Returns: A string, with all the authentication requirement information.
     */
    class func authentication() -> String {
        //encoding the hardware signature required by the server.
        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
        
        //adding the prefix.
        let hwsig = "CS-" + encodedHwsig
        
        //createa a completed string with all the necessary informations.
        let tempStr = "?service=\(serviceName)&caller-hw-description=\(UIDevice.current.modelName() + "," + UIDevice.current.name)&USERID=\(username)&PASSWD=\(password)&HWSIG=\(hwsig.uppercased())"
        
        //converting it into a valid url format.
        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    /**
     This method is used to create desired response URL with necessary informations required to complete the challenge authentication. Since the communication is done interactively, so the password is not send to the server, just the service name and username is send to the server, and in response server sends different challenges in order to complete the authentication.
     
     - Returns : A string value containing all the neccessary informations inorder to communicate with the server.
     */
    class func challengeAuthentication() -> String {
        //encoding the hardware signature required by the server.
        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
        
        //adding the prefix.
        let hwsig = "CS-" + encodedHwsig
        
        //createa a completed string with all the necessary informations.
        let tempStr = "?service=\(serviceName)&caller-hw-description=\(UIDevice.current.modelName() + "," + UIDevice.current.name)&USERID=\(username)&HWSIG=\(hwsig.uppercased())"
        
        //converting it into a valid url format.
        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    /**
     This method is used to generate the response URL for the challenge Authentication with the challenge name and their corresponding user response. All the information is appended in the base URL and is send to the server to complete the challenge.
     
     - Parameter aArrDictionary: This is an array of dictionary containing the name of challenge and their reponse in the key value pair format.
     - Returns: A url with appended response from the user.
     */
    class func challengeAuthenticationURL(challenge aArrDictionary:[[String:Any]]) -> String {
        //retrieving the array.
        let arr = aArrDictionary

        //encoding the hardware signature required by the server.
        let encodedHwsig = Utilities.sha256(securityString: HWSIGCalc.calcHwSignature())
        
        //adding the prefix.
        let hwsig = "CS-" + encodedHwsig
        
        var passStr = ""
        for dict in arr {
            
            for (key,value) in dict {
                passStr = value as! String//.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        //createa a completed string with all the necessary informations.
        let tempStr = "?service=\(serviceName)&caller-hw-description=\(UIDevice.current.modelName() + "," + UIDevice.current.name)&USERID=\(username)&PASSWD=\(passStr)&HWSIG=\(hwsig.uppercased())"
        
        //converting it into a valid url format.
        let urlStr = tempStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return urlStr
    }
    
    /**
     This method is used to get the desired information in the request to complete the challenges.
     - Returns: A url string,to complete the challenges.
     */
    class func challengeAuthentication(_ challengeName:String,_ challengeValue:String) -> String {
        let tempChallengeResponse = /*"/rcdp/2.2.0/authentication?responses=*/"\(Utilities.sha256(securityString:challengeName))+\(Utilities.sha256(securityString: challengeValue))"
        let returnChallengeStr = tempChallengeResponse.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return returnChallengeStr!
    }
    
    /**
     This method is used to get the valid time token required to complete handshaking with the server, as the server needs the date and time zone in the ISO8601 Date format inorder to complete the handshaking.
     - Returns: The date formatted string in the ISO8601 Date format.
     */
    class private func getISO8601DateFormat() -> String {
        let dateFormatter = DateFormatter()
        
        //sets the time zone to GMT.
        let timeZone = TimeZone.init(identifier: "GMT")
        
        //sets the time zone in the date format.
        dateFormatter.timeZone = timeZone
        
        //sets the date format.
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'"
        
        //sets the current device date and time in the format of the dateFormatter.
        var iso8601String = dateFormatter.string(from: Date())
        
        //omitting the AM and PM value in the formatted string.
        if iso8601String.range(of: "A") != nil  {
            iso8601String = iso8601String.replacingOccurrences(of: "AM", with: "")
        }else if  iso8601String.range(of: "P") != nil {
            iso8601String = iso8601String.replacingOccurrences(of: "PM", with: "")
        }
        print("FormatISO8601String::\(iso8601String)")
        //returns a valid string ,that is url compatible.
        return iso8601String.replacingOccurrences(of: ":", with: "%3A").replacingOccurrences(of: " ", with: "")
    }
}
