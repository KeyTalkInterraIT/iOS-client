//
//  VCModel.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation

class ImportModel {
    
    let apiService = ConnectionHandler()
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    func requestForDownloadRCCD(downloadUrl: URL, systemfile: @escaping (_ localUrl: URL?) -> ()) {
        self.isLoading = true
        apiService.downloadFile(url: downloadUrl) { (url, message) in
            self.isLoading = false
            if message != nil {
                self.alertMessage = message!
            }
            else {
                if let url = url {
                    let localFileUrl = self.urlForDownloadedRCCD(systemUrl: url)
                    systemfile(localFileUrl)
                }
            }
        }
    }
    
    func urlForDownloadedRCCD(systemUrl: URL) -> URL? {
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        let filePath = docsDirectory.appending("/downloaded.rccd")
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        do {
            try fileManager.moveItem(atPath: systemUrl.path, toPath: filePath)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        return URL(string: "file://" + filePath)
    }
    
    func getDownloadURLString(aDownloadStr: String) -> String {
        var urlString = aDownloadStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "http://" + urlString
        }
        if !urlString.lowercased().hasSuffix(".rccd") {
            urlString = urlString + ".rccd"
        }
        
        return urlString
    }
}

