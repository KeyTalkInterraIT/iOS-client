//
//  Connection.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//

import Foundation
import UIKit


//The Base class for server connection.
class Connection: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    static private var keyTalkCookie = ""
    
    //connection static object
    static private let shared = Connection()
    
    //static session object
    static private var sUrlSession: URLSession? = nil
    
    /**
     This method is used to initialize the URLSession static varible with the shared connection instance.
     */
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
    
    /**
     This method is used to make the connection with the server and to fetch the response from the server side.
     The session callback is send to the completion handler with the appropriate message.
     - Parameter urlRequest: The request for which the connection task is to be done.
     */
    class func hitService(urlRequest: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) -> Void {
        
        //establish the connection with the server for the request.
        Connection.urlSession().dataTask(with: urlRequest) { (data, response, error) in
            //data -- data server sends.
            //response -- response from the server.
            //error -- if any error occurs during the session.
            
            
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
                
                //gets the response from the server.
                guard let tempHttpResponse = response as? HTTPURLResponse else {
                    //notify that the communication has failed.
                    completionHandler(false, "Something_went_wrong_try_again".localized(KTLocalLang))
                    return
                }
                print("Status:\n\(tempHttpResponse.statusCode)")
                print("Headers:::\n\(tempHttpResponse.allHeaderFields)")
            
                //if the connection status is successfully.
                if tempHttpResponse.statusCode == 200 {
                    let dict = tempHttpResponse.allHeaderFields
                                        
                    if dict["Set-Cookie"] != nil {
                        //sets the cookies value into the global variable.
                        keytalkCookie = dict["Set-Cookie"] as! String
                    }
                    
                    if let _data = data {
                        //sets the global variable with the data send by the server.
                        dataCert = _data
                        let str = String.init(data: _data, encoding: .utf8)
                        print("ResponseString:::\n\(str ?? "")")
                        logStr = logStr + "," + (str ?? "")
                        logStr = "\(NSDate())       " + logStr
                        //notify that the communication is completed.
                        completionHandler(true, nil)
                    } else {
                        //notify that the communication has failed.
                        completionHandler(false, nil)
                    }
                }
                else {
                    completionHandler(false, "Something_went_wrong_try_again".localized(KTLocalLang))
                }
            }
            //save the log data in the database.
            Utilities.saveToLogFile(aStr: logStr)
            
        }.resume()
    }
    
    /**
     This method is used to initiate the server communication.
     */
    class func makeRequest(request: URLRequest, completionHandler: @escaping (_ success: Bool, _ message: String?) -> Void) {
        
        //sends to establish the connection
        hitService(urlRequest: request) { (success, message) in
            if success {
                //notify the success of the communication.
                completionHandler(true, nil)
            }
            else {
                //notify the failure of the communication.
                completionHandler(false, message)
            }
        }
    }
    
    /**
     This method is used to download a file from the url. And if the file is successfully downloaded, then they notify the completionHandler with the system file path at which the file have been donwloaded to.
     */
    class func downloadFile(request: URLRequest, completionHandler: @escaping (_ fileUrl: URL?, _ message: String?) -> ()) {
        urlSession().downloadTask(with: request) { (systemUrl, response, error) in
            if let error = error {
                completionHandler(nil, error.localizedDescription)
            }
            else {
                //gets the response from the server.
                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(nil, "Something_went_wrong_try_again".localized(KTLocalLang))
                    return
                }
                //if status is successful
                if httpResponse.statusCode == 200 {
                    //sends the system url at which the file is downloaded.
                    completionHandler(systemUrl, nil)
                }
                else {
                    completionHandler(nil, "Something_went_wrong_try_again".localized(KTLocalLang))
                }
            }
        }.resume()
    }
    
    //MARK:- URLSessionDelegate Methods.
    
    //Delegate to handle the validation of the TLS handshake. Used to validate that we are communicating with the correct Keytalk Server. This is done by comparing the complete certificate with the received one from the server.
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        if (challenge.protectionSpace.protocol == "https"){
            let trust = challenge.protectionSpace.serverTrust
            if let serverTrust = trust {
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                if let _certificate = certificate {
                    let credential: URLCredential = URLCredential(trust: serverTrust)
                    //the server is trusted since the certificates matched.
                    completionHandler(.useCredential, credential)
                } else {
                    //if unable get the certificate, then ends the server authentication.
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
        } else {
            //ends the server authentication.
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}


 



