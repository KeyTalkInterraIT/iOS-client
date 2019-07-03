//
//  ConnectionHandler.swift
//  KeyTalk
//
//  Created by Paurush on 6/12/18.
//

import Foundation

class ConnectionHandler {
    
    /**
     This method is used to send the request to the server to establish the connection with the server and to fetch the response for that request from the server.
     
     - Parameter forURLType: The type of url for which the connection is to be established.
     
     if the status of the connection is notified to the completionHandler with a bool value.
     */
    func request(forURLType:URLs, completionHandler: @escaping (_ success: Bool, _ message: String?) -> ()) {
        Connection.makeRequest(request: getRequest(urlType: forURLType)) { (success, message) in
            //if the connection is established successfully.
            if success {
                do {
                    //retrives the response from the server.
                    let data = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
                    if let data = data {
                        //gets the status of the communication.
                        guard let status = data["status"] as? String else {
                            completionHandler(false, "Something_went_wrong_try_again".localized(KTLocalLang))
                            return
                        }
                        if status == "eoc" {
                            //notifies that the commnication has ended.
                            completionHandler(false, "End_communication".localized(KTLocalLang))
                        }
                        else {
                            //notifies the success of the commnication.
                            completionHandler(true, nil)
                        }
                    }
                    else {
                        //notifies the failure in the commnication.
                        completionHandler(false, "Something_went_wrong_try_again".localized(KTLocalLang))
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                    completionHandler(false, "Something_went_wrong_try_again".localized(KTLocalLang))
                }
            }
            else {
                completionHandler(false, message)
            }
        }
    }
    
    /**
     This function is used to download the file by establishing the connectivity and communicating with the server.
     If the file is succesfully downloaded , then the completionHandler is notified with the file path at which the file is downloaded to.
     - Parameter url: The url from which the file is to be downloaded.
     */
    func downloadFile(url: URL, completionHandler: @escaping (_ fileurl: URL?, _ message: String?) -> ()) {
        // request initiated.
        let request = URLRequest.init(url: url)
        
        //server request is started to download the file.
        Connection.downloadFile(request: request) { (fileUrl, message) in
            if let message = message {
                //if download fails.
                completionHandler(nil, message)
            }
            else {
                //if download is successful,notifes with the downloaded path.
                completionHandler(fileUrl, nil)
            }
        }
    }
    
    /**
     This method is used to get the request needed to establish the communication with the server according to the URL type. Here all the URLRequest necessary properties are set.
     - Parameter urlType: The type of url for which the request needs to be created.
     - Returns : A url request needed to establish a connection.
     */
    private func getRequest(urlType: URLs) -> URLRequest {
        //gets the url of the server.
        let url = Server.getUrl(type: urlType)
        print("Url::::::: \(String(describing: url))")
        //initiates the request.
        var request = URLRequest.init(url: url!)
        
        //set the time duration of the request.
        request.timeoutInterval = 60
        
        //set the http methods to retrive the data.
        request.httpMethod = "GET"//HTTP_METHOD_POST
        if !keytalkCookie.isEmpty {
            //adds cookie in the header of the request.
            request.addValue(keytalkCookie, forHTTPHeaderField: "Cookie")
            request.addValue("identity", forHTTPHeaderField: "Accept-Encoding")
        }
        return request
    }
}
