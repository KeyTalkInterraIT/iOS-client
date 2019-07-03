//
//  VCModel.swift
//  KeyTalk
//
//  Created by Paurush on 6/12/18.
//

import Foundation

class VCModel {
    
    //communication object.
    let apiService = ConnectionHandler()
    
    //variable to notify the loader.
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    //variable notified when message is recieved.
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    //variabe notified when delay is recieved.
    var delayTime : Int? {
        didSet {
            self.delayTimeClosure?()
        }
    }
    
    //variable to notify the success of server api hit.
    var isApiSucceed: Bool = false {
        didSet {
            self.successFullResponse?(typeURL)
        }
    }
    
    //variable notified when challenge is recieved.
    var isChallengeEncountered:Bool? {
        didSet {
            self.showChallengeClosure?(typeChallenge,valueChallenge)
        }
    }
    
    //type of url for the server comminication.
    var typeURL: URLs = .hello
    
    //type and value of the Challenge
    var valueChallenge:String = String()
    var typeChallenge : ChallengeResult = .PassWordChallenge
    
    //Closure for all the declared variables, called in the parent class.
    var delayTimeClosure: (()->())?
    var showAlertClosure: (()->())?
    var showChallengeClosure: ((ChallengeResult,String)->())?
    var updateLoadingStatus: (()->())?
    var successFullResponse: ((URLs)->())?
    var downloadRCCD: (()->())?
    
    
    /**
     This method is used to communicating with the keytalk server
          - Parameter urlType: The type of url for which the communication needs to be done.
     */
    func requestForApiService(urlType: URLs) {
        typeURL = urlType
        //sets the variable to true, inorder to start the loader.
        self.isLoading = true
        
        //sends the request for server communication.
        apiService.request(forURLType: urlType) { [unowned self] (success, message) in
            //if communication is successfull.
            
            //sets the variable to false, inorder to stop the loader.
            self.isLoading = false
            if message != nil {
                //variable notified, since a message is recieved.
                self.alertMessage = message!
            }
            else {
                //handle the response of the communication, according to the URL TYPE.
                self.handleResponseAccToUrlType(urlType: urlType)
            }
        }
    }
    
    /**
     This method is used to communicate with the server to download the RCCD file.
     
     - Parameters downloadUrl: the URL through which the rccd file needs to be downloaded.
     */
    func requestForDownloadRCCD(downloadUrl: URL, systemfile: @escaping (_ localUrl: URL?) -> ()) {
        //sets the variable to true, inorder to start the loader.
        self.isLoading = true
        
        //sends the request to download the file from the url given.
        apiService.downloadFile(url: downloadUrl) { (url, message) in
            //if communication is successfull.
            
            //sets the variable to false, inorder to stop the loader.
            self.isLoading = false
            if message != nil {
                //variable notified, since a message is recieved.
                self.alertMessage = message!
            }
            else {
                //move the downloaded file from the local directory to the system directory.
                if let url = url {
                    //sets the system url at which the file needs to be saved.
                    let localFileUrl = self.urlForDownloadedRCCD(systemUrl: url)
                    
                    //moving the file from the local directory to the system directory.
                    systemfile(localFileUrl)
                }
            }
        }
    }
    
    /**
        This method is used to handle the response according to the URL type.
     - Parameter urlType: The type of url for which the response handling needs to be done.
     */
    func handleResponseAccToUrlType(urlType: URLs) {
        switch urlType {
        case .hello:
            //sets the variable to true, inorder to notify the communication is successfull.
            self.isApiSucceed = true
        case .handshake:
            //sets the variable to true, inorder to notify the communication is successfull.
            self.isApiSucceed = true
        case .authReq:
            //calls to handle the authentication requirements.
            self.handleAuthReq()
        case .authentication:
            //calls to handle the authentication response.
            self.handleAuthentication()
        case .challenge:
            //sets the variable to true, inorder to notify the communication is successfull.
            self.handleAuthentication()
        case .certificate:
            //sets the variable to true, inorder to notify the communication is successfull.
            self.isApiSucceed = true
         }
    }
    
    /**
     This method is used to handle the authentication requirements response, inorder to complete the authetication process. The authentication response will be parsed to find out the authentication requirements and will be stored locally.
     */
    private func handleAuthReq() {
        do {
            //gets the dictionary for the server reponse.
            let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                if dictValue["credential-types"] != nil {
                    //getting the credentials required, inorder to complete the authentication
                    guard let arr = dictValue["credential-types"] as? [String] else {
                        return
                    }
                    
                    //if requirements contains hardware signature.
                    if arr.contains("HWSIG") {
                        
                        //sets the global varible to true.
                        hwsigRequired = true
                        
                        //retrives the formula for the hardware signature.
                        let formula = dictValue["hwsig_formula"] as? String
                        if let formula = formula {
                            //save the hardware signature formula locally.
                            HWSIGCalc.saveHWSIGFormula(formula: formula)
                        }
                    }
                    else {
                        //sets the global varible to false.
                        hwsigRequired = false
                    }
                }
            }
            //sets the variable to true, inorder to notify the communication is successfull.
            self.isApiSucceed = true
        }
        catch let error {
            //variable notified, since a erro message is recieved.
            self.alertMessage = error.localizedDescription
        }
    }
    
    /**
        This method is used after the authentication requirements have been fulfilled.
        The server generates different kinds of authentication status to notify the communication status.
        Thus the authentication status denotes the result of the authentication, if status is OK, then only the certificates can be downloaded , rest all other status means that authentication is not successfull at this moment.
     */
    private func handleAuthentication() {
        do {
            //gets the dictionary for the server reponse.
            let dict = try JSONSerialization.jsonObject(with: dataCert, options: .mutableContainers) as? [String : Any]
            if let dictValue = dict {
                //retrieves the authentication status from the dictionary.
                if dictValue["auth-status"] != nil {
                    guard let authStatus = dictValue["auth-status"] as? String else {
                        return
                    }
                    
                    //since the auth status can be of different types, so handle on the basis of Auth Result.
                    switch authStatus {
                    case AuthResult.ok.rawValue:
                        //if the auth result is OK, then the communication is successful and the certificate can be retrieved.
                        self.isApiSucceed = true
                    case AuthResult.delayed.rawValue:
                        //if auth result is delay, then the communication is not successful and the user have to try again after the delay time.
                        
                        //gets the delay time from the reponse.
                        let delay = dictValue[authStatus.lowercased()] as! String
                        
                        //notify the Timer , that the delay have been encountered.
                        self.delayTime = Int(delay)
                        
                        //notify the alert, as a message is recieved.
                        self.alertMessage = "\("delay_message_alert".localized(KTLocalLang)) \(delay) \("seconds_string".localized(KTLocalLang))."
                    case AuthResult.locked.rawValue:
                        //if auth status is locked, then the user is locked at the server side and cannot communicate.
                        //notify the alert, as a message is recieved.
                        self.alertMessage = "locked_message_alert".localized(KTLocalLang)
                    case AuthResult.expired.rawValue:
                        //if auth status is expired, then the password has been expired and the user have to update their password.
                        //notify the alert, as a message is recieved.
                        self.alertMessage = "password_update_message_alert".localized(KTLocalLang)
                    case AuthResult.challenge.rawValue:
                        //if auth status is challenge, then the user have to pass all the challenges which have been encountered in the response.
                        
                        //retriving all the challenges encountered in the response in an array.
                        let challengeArr = dictValue["challenges"] as! [[String:Any]]
                        
                        //calls to handle the challenges.
                        self.handleChallenges(aChallengeArr: challengeArr)
                    default:
                        print("Status unrecognised")
                    }
                }
            }
        }
        catch let error {
            //notify the alert, as a error message is recieved.
            self.alertMessage = error.localizedDescription
        }
    }
    
    /**
     This method is used to handle all the challenges encountered by the user.
     - Parameter aChallengeArr: An array of challenges encountered.
     */
    private func handleChallenges(aChallengeArr : [[String:Any]]) {
        var challengeDict = [String:Any]()
        //iterating through the challenges array.
        for element in aChallengeArr {
            //eliminating the element from the array, Dictionary type.
            challengeDict = element
        }
        
        //gets the type of challenge encountered.
        guard let challengetype = challengeDict["name"] as? String else {
            return
        }
        //gets the value of challenge encountered.
        guard let _challengeValue = challengeDict["value"] as? String else {
            return
        }
        
        //sets the challenge value.        
        self.valueChallenge = _challengeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        switch challengetype {
        case ChallengeResult.PassWordChallenge.rawValue:
            //New Token Challenge.
            self.typeChallenge = ChallengeResult.PassWordChallenge
            //notify that the challenge is encountered.
            self.isChallengeEncountered = true
        default:
            print("Invalid challenge encountered.")
        }
    }
    
    /**
     This method is used to get the url for the downloaded RCCD file after moving it from the current directory.
     - Parameter systemUrl: A system url of the downloaded RCCD file.
     - Returns : A local url at which the file have been moved to.
     */
    func urlForDownloadedRCCD(systemUrl: URL) -> URL? {
        //gets the document directory path.
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        //appending in the document directory.
        let filePath = docsDirectory.appending("/downloaded.rccd")
        
        //checks wheather the file already exists or not.
        if fileManager.fileExists(atPath: filePath) {
            do {
                //if exist, then removed.
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        do {
            //move the file from the system url to the document directory path.
            try fileManager.moveItem(atPath: systemUrl.path, toPath: filePath)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        //returns a valid file path.
        return URL(string: "file://" + filePath)
    }
    
    /**
     This method is used to get the valid url needed to download the rccd file.
     - Parameter aDownloadStr: the url in the string format, which need to be validated.
     - Returns : A valid url, through which the rccd file can be downloaded.
     */
    func getDownloadURLString(aDownloadStr: String) -> String {
        //trims the white spaces and new lines.
        var urlString = aDownloadStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //check wheather the string contains prefix, if not then append the prefix.
        if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        //check the suffix, if not present, then append it at the end of it.
        if !urlString.lowercased().hasSuffix(".rccd") {
            urlString = urlString + ".rccd"
        }
        
        return urlString
    }
    
    /**
        This method is used to get the last username and last service which the user have used.
     
     - Returns : username and the corresponding service name which was last used..
     */
    func toCheckLastUsedServiceAndUsername() -> (String?, String?) {
        if let user = UserDetailsHandler.getLastSavedEntry() {
            return (user.service, user.username)
        }
        return (nil, nil)
    }
}
