//
//  Connection.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit

class Connection: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    static private var keyTalkCookie = ""
    
    static private let shared = Connection()
    static private var sUrlSession: URLSession? = nil
    class private func urlSession() -> URLSession {
        if (sUrlSession == nil) {
            #if false
                sUrlSession = URLSession.shared
            #else
                let urlSessionConfiguration = URLSessionConfiguration.default
                urlSessionConfiguration.urlCache = nil
                
                sUrlSession = URLSession(configuration: urlSessionConfiguration, delegate: Connection.shared, delegateQueue: nil)
            #endif
        }
        
        return sUrlSession!
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        let trust = challenge.protectionSpace.serverTrust
        let urlCredential = URLCredential.init(trust: trust!)
        completionHandler(.useCredential, urlCredential)
    }
    
    class func hitService(urlRequest: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) -> Void {
        Connection.urlSession().dataTask(with: urlRequest) { (data, response, error) in
            
            var logStr = urlRequest.url!.absoluteString
            if logStr.contains("&HWSIG") {
                logStr = logStr.components(separatedBy: "&PASSWD")[0]
            }
            
            if let lTempError = error {
                logStr = logStr + "," + lTempError.localizedDescription
                print(lTempError.localizedDescription)
                completionHandler(false, lTempError.localizedDescription)
            }
            else {
                let tempHttpResponse = response as! HTTPURLResponse
                print("Status:\n\(tempHttpResponse.statusCode)")
                print("Headers:::\n\(tempHttpResponse.allHeaderFields)")
            
                if tempHttpResponse.statusCode == 200 {
                    let dict = tempHttpResponse.allHeaderFields
                    if dict["Set-Cookie"] != nil {
                        keytalkCookie = dict["Set-Cookie"] as! String
                    }
                    dataCert = data!
                    let str = String.init(data: data!, encoding: .utf8)
                    print("ResponseString:::\n\(str ?? "")")
                    logStr = logStr + "," + (str ?? "")
                    completionHandler(true, nil)
                }
                else {
                    completionHandler(false, "Something went wrong. Please try again.")
                }
//                logStr = logStr + "," + Utilities.proivdeStringForResponse(response: tempHttpResponse)
            }
            Utilities.saveToLogFile(aStr: logStr)
            
        }.resume()
    }
    
    class func makeRequest(request: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {
        
        hitService(urlRequest: request) { (success, message) in
            if success {
                completionHandler(true, nil)
            }
            else {
                completionHandler(false, message)
            }
        }
    }
    
    class func downloadFile(request: URLRequest, completionHandler: @escaping (_ fileUrl: URL?, _ message: String?) -> ()) {
        urlSession().downloadTask(with: request) { (systemUrl, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    completionHandler(systemUrl, nil)
                }
                else {
                    completionHandler(nil, "Something went wrong. Please try again.")
                }
            }
        }.resume()
    }
}



