//
//  ConnectionHandler.swift
//  KeyTalk
//
//  Created by Paurush on 6/12/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation

class ConnectionHandler {
    
    func request(forURLType:URLs, completionHandler: @escaping (_ success: Bool, _ message: String?) -> ()) {
        Connection.makeRequest(request: getRequest(urlType: forURLType)) { (success, message) in
            if success {
                do {
                    let data = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
                    if let data = data {
                        let status = data["status"] as! String
                        if status == "eoc" {
                            completionHandler(false, "End of communication.")
                        }
                        else {
                            completionHandler(true, nil)
                        }
                    }
                    else {
                        completionHandler(false, "Something went wrong. Please try again.")
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                    completionHandler(false, "Something went wrong. Please try again.")
                }
            }
            else {
                completionHandler(false, message)
            }
        }
    }
    
    func downloadFile(url: URL, completionHandler: @escaping (_ fileurl: URL?, _ message: String?) -> ()) {
        let request = URLRequest.init(url: url)
        Connection.downloadFile(request: request) { (fileUrl, message) in
            if let message = message {
                completionHandler(nil, message)
            }
            else {
                completionHandler(fileUrl, nil)
            }
        }
    }
    
    private func getRequest(urlType: URLs) -> URLRequest {
        let url = Server.getUrl(type: urlType)
        print("Url::::::: \(url)")
        var request = URLRequest.init(url: url)
        request.timeoutInterval = 60
        request.httpMethod = "GET"//HTTP_METHOD_POST
        if !keytalkCookie.isEmpty {
            request.addValue(keytalkCookie, forHTTPHeaderField: "Cookie")
            request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
        }
        return request
    }
    
}
