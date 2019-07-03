//
//  VCModel.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.


import Foundation

class ImportModel {
    
    /**
    //object for creating connection.
    let apiService = ConnectionHandler()

    /**
     object to notify the loader.
     if false,will stop the loader.
     if true, loader will continue.
     */
    var isLoading: Bool = false {
        didSet {
            //when isLoading is set, will call this closure.
            self.updateLoadingStatus?()
        }
    }

    /**
     object used to assign the alert message during the server communication.
     */
    var alertMessage: String? {
        didSet {
            //when alertmessage is set, this closure will be called.
            self.showAlertClosure?()
        }
    }
    
    //closure for alertmessage
    var showAlertClosure: (()->())?
    //closure for loading status
    var updateLoadingStatus: (()->())?
    
    /**
     This method is used to download a rccd file from a url and to save it in the local system.
     
     - Parameters downloadURL: The url at which the rccd is placed.
     */
    func requestForDownloadRCCD(downloadUrl: URL, systemfile: @escaping (_ localUrl: URL?) -> ()) {
        //starts the loader
        self.isLoading = true
        //calls the server connection class method inorder to download the file. it will return a local system url and a corresponding message.
        apiService.downloadFile(url: downloadUrl) { (url, message) in
            //stop the loader
            self.isLoading = false
            if message != nil {
                //sets the alert message with the message provided by the comminication class.
                self.alertMessage = message!
            }
            else {
                if let url = url {
                    //sets the local system file url at which the rccd file will be downloaded to.
                    let localFileUrl = self.urlForDownloadedRCCD(systemUrl: url)
                    systemfile(localFileUrl)
                }
            }
        }
    }
    
    /**
     This method is used to get the system path at which the downloaded rccd file is been stored.
     
     - Parameters systemUrl: The system url at which the file will be kept.
     - Returns: The local file url at which the file is stored.
     */
    func urlForDownloadedRCCD(systemUrl: URL) -> URL? {
        
        //object for document directory.
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        //appending in the document directory
        let filePath = docsDirectory.appending("/downloaded.rccd")
        
        //checks wheather the file already exists at the current path.
        if fileManager.fileExists(atPath: filePath) {
            do {
                //remove that file at that path.
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        do {
            //moves the file from the system url to document directory.
            try fileManager.moveItem(atPath: systemUrl.path, toPath: filePath)
        }
        catch let error {
            print(error.localizedDescription)
        }
        //returns the local file path.
        return URL(string: "file://" + filePath)
    }
    
    /**
     This funtion is used to generate a valid URL needed to download the rccd file.
     
     - Parameters aDownloadStr: The url entered by the user.
     - Returns: A valid url through which the rccd file can be downloaded.
     */
    func getDownloadURLString(aDownloadStr: String) -> String {
        //trimming the white spaces in the urlString
        var urlString = aDownloadStr.trimmingCharacters(in: .whitespacesAndNewlines)
        //checks wheather the url contains 'http' and 'https', if not the append 'http' before the url.
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            //appending 'http' before the url.
            urlString = "http://" + urlString
        }
        //checks wheather the url contains the '.rccd' extention, if not then append '.rccd' at the last of the url.
        if !urlString.lowercased().hasSuffix(".rccd") {
            urlString = urlString + ".rccd"
        }
        
        //returns a valid url.
        return urlString
    }*/
}

