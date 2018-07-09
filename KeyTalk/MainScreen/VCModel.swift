//
//  VCModel.swift
//  KeyTalk
//
//  Created by Paurush on 6/12/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation

class VCModel {
    
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
    
    var isApiSucceed: Bool = false {
        didSet {
            self.successFullResponse?(typeURL)
        }
    }
    
    var typeURL: URLs = .hello
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var successFullResponse: ((URLs)->())?
    var downloadRCCD: (()->())?
    
    func requestForApiService(urlType: URLs) {
        typeURL = urlType
        self.isLoading = true
        apiService.request(forURLType: urlType) { [unowned self] (success, message) in
            self.isLoading = false
            if message != nil {
                self.alertMessage = message!
            }
            else {
                self.handleResponseAccToUrlType(urlType: urlType)
            }
        }
    }
    
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
    
    func handleResponseAccToUrlType(urlType: URLs) {
        switch urlType {
        case .hello:
            self.isApiSucceed = true
        case .handshake:
            self.isApiSucceed = true
        case .authReq:
            self.handleAuthReq()
        case .authentication:
            self.handleAuthentication()
        case .certificate:
            self.isApiSucceed = true
        default:
            print("Nothing to do")
        }
    }
    
    private func handleAuthReq() {
        do {
            let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                if dictValue["credential-types"] != nil {
                    let arr = dictValue["credential-types"] as! [String]
                    if arr.contains("HWSIG") {
                        hwsigRequired = true
                        let formula = dictValue["hwsig_formula"] as? String
                        if let formula = formula {
                            HWSIGCalc.saveHWSIGFormula(formula: formula)
                        }
                    }
                    else {
                        hwsigRequired = false
                    }
                }
            }
            self.isApiSucceed = true
        }
        catch let error {
            self.alertMessage = error.localizedDescription
        }
    }
    
    private func handleAuthentication() {
        do {
            let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                if dictValue["auth-status"] != nil {
                    let authStatus = dictValue["auth-status"] as! String
                    switch authStatus {
                    case AuthResult.ok.rawValue:
                        self.isApiSucceed = true
                    case AuthResult.delayed.rawValue:
                        let delay = dictValue[authStatus.lowercased()] as! String
                        self.alertMessage = "Something went wrong. Please try again after \(delay) seconds."
                    case AuthResult.locked.rawValue:
                        self.alertMessage = "User is locked on server. Please check with your administrator."
                    case AuthResult.expired.rawValue:
                        self.alertMessage = "Password is expired. Please update your password."
                    case AuthResult.challenge.rawValue:
                        print("ok")
                    default:
                        print("Status unrecognised")
                    }
                }
            }
        }
        catch let error {
            self.alertMessage = error.localizedDescription
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
    
    func toCheckLastUsedServiceAndUsername() -> (String?, String?) {
        if let user = UserDetailsHandler.getLastSavedEntry() {
            return (user.service, user.username)
        }
        
        return (nil, nil)
    }
}
