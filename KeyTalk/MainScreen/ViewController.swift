//
//  ViewController.swift
//  KeyTalk
//
//  Created by Paurush on 5/15/18.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate ,KTHardwareAuthenticationDelegate {
    
    @IBOutlet var textFieldService: UITextField!
    @IBOutlet var textFieldUsername: UITextField!
    @IBOutlet var textFieldPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var imgLogo: UIImageView!
    @IBOutlet var challengeTypeLbl:UILabel!
    @IBOutlet var textFieldChallenge:UITextField!
    //@IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var lblAuthenticate: UILabel!
    @IBOutlet weak var lTrustcert: UIButton!
    @IBOutlet var lblPleasewait: UILabel!
    @IBOutlet var lbllongpresspassword: UILabel!
    @IBOutlet var lbltranfertosafari: UILabel!
    @IBOutlet weak var okChallengeButton: UIButton!
    
    var selectedUserModel: UserModel?
    var tblSearch: UITableView?
    var comingFromDidSelect = false
    
    // Services array
    var services = [UserModel]()
    var filteredServices = [UserModel]()
    var beforeSearchFilteredServices = [UserModel]()
    
    // Models
    var model: RCCDLogic?
    let vcmodel = VCModel()
    
    var certificateUrl: URL!
    
    // Timer
    var timer = Timer()
    var isTimerRunning = false
    var delayTimeInSeconds : Int = 0
    
    // Selected Servie
    var currentSelectedService :String = String()
    var lastSelectedService :String = String()
    
    // App launch check variable
    static var isAppAlreadyLaunched = false

    //Challenge Variable
    var challengeMessage = String()
    
    //MARK:- LifeCycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Initial method when the app initiates
        
        lblAuthenticate.text = "Authenticate_string".localized(KTLocalLang)
        textFieldService.placeholder = "KeyTalk_service_string".localized(KTLocalLang)
        textFieldUsername.placeholder = "username_string".localized(KTLocalLang)
        textFieldPassword.placeholder = "Password_string".localized(KTLocalLang)
        lTrustcert.setTitle("trust_button_string".localized(KTLocalLang), for: .normal)
        btnLogin.setTitle("Authenticate_string".localized(KTLocalLang), for: .normal)
        lblPleasewait.text = "please_wait_string".localized(KTLocalLang)
        lbllongpresspassword.text = "long_press_password_strong".localized(KTLocalLang)
        lbltranfertosafari.text = "transfer_to_safari_string".localized(KTLocalLang)
        okChallengeButton.setTitle("ok_string".localized(KTLocalLang), for: .normal)
        
        beginActivationMethod()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        showTable(hidden: true)
    }
    
    //MARK:- objc methods
    
    /**
     Action/Target method to be called, when the app doesn't contains any RCCD file.
     */
    @objc private func moveToImportPageIfNoService() {
        if DBHandler.getServicesData().count == 0 {
            self.performSegue(withIdentifier: "importRCCD", sender: nil)
            print("moved to import page")
        }
    }
    /**
     Action/Target method to be called, when the keyboard will be visible.
     */
    @objc private func keyboardWillShow(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let tempKeyboardHeight = keyboardRectangle.height
            keyBoardHeight = tempKeyboardHeight
            updateTableHeight(height: Utilities.calculateHeightForTable(yOfTable: getPoint().y))
        }
    }
        
    /**
     Action/Target method to be called, to Update the timer with the updated delay time.
     */
    @objc func updateTimer() {
        handleAfterDelay(isTimerRunning)
    }
    
    /**
     Action/Target method to be called,when the textfield is edited.
     */
    @objc private func textChanged(textField: UITextField) {
        updateValue()
    }
    
    /**
     Method used to set up the updated data on the view.
     */
    func refreshData() {
        //sets up the view
        setUpData()
        
        //updates the view , when the rccd file is imported.
        onSuccessfullRccdImport()
    }
    
    // MARK:- Private
    
    /*
     * adding a target on the services textfield.
     */
    private func addEventOnTextFieldService() {
            textFieldService.addTarget(self, action: #selector(textChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    
    /**
     Initial method when the app initiates, to find out wheather the biometric validation is to done or not.
     */
    private func beginActivationMethod() {
        //if the app is just launched or started.
        if !ViewController.isAppAlreadyLaunched {
            //sets the static variable to true, to denote that the app have started.
            ViewController.isAppAlreadyLaunched = true
        
            //check wheather user have activated the app lock.
            let isAppLockEnabled = UserDefaults.standard.value(forKey: "appLockState") as? Bool
            if let _isAppLockEnabled = isAppLockEnabled {
                if _isAppLockEnabled {
                    //if app lock is enabled.
                    self.view.viewWithTag(111)?.isHidden = false
                    //starts the biometric authentication.
                    validateUser()
                }
                else{
                    //if app lock is disabled.
                    handleAfterUserAuthenication()
                }
            } else {
                //initially sets the app lock value to default, i.e false
                UserDefaults.standard.set(false, forKey: "appLockState")
                handleAfterUserAuthenication()
            }
        }
    }
    
    /**
     This method is used to set up the whole view for the services screen.
     */
    private func setupView() {
        //Rendering view ,for iphoneX.
        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
        
        //work around to find the height of the drop down menu.
        setupKeyboardHack()
        
        //fill the view with the data.
        setUpModel()
        setUpData()
        setUpTableServices()
        setUpTextIfAny()
        addEventOnTextFieldService()
        if filteredServices.count > 0 {
            if let user = UserDetailsHandler.getLastSavedEntry(){
                self.textFieldService.text = user.service
            }
            else{
            self.textFieldService.text = filteredServices[0].Providers[0].Services[0].Name
            }
        }
    }
    
    /**
     This method is used to initiate the validation or Authentication of the user through touchID/faceID or passcode.c
     */
    private func validateUser()
    {
        guard let biometricView = self.view.viewWithTag(111) else {
            return
        }
        biometricView.isHidden = false
        
        //sets the base class for the biometric validation, inorder to get the validation callback.
        let biometricValidation : KTHardwareAuthentication = KTHardwareAuthentication(obj: self)
        
        //calls for the validation process to start.
        biometricValidation.verifyWithTouchIdFaceIDorPasscode()
    }
    
    // workaround to set the drop down menu.
    private func setupKeyboardHack() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        ///// WorkAround to get height of keyboard
        let field = UITextField()
        UIApplication.shared.windows.last?.addSubview(field)
        field.becomeFirstResponder()
        field.resignFirstResponder()
        field.removeFromSuperview()
    }
    
    //Update the height according to the devices.
    func updateTableHeight(height: CGFloat) {
        if let tempSearchTable = tblSearch {
            if screenHeight > 568 {
                var frame = tempSearchTable.frame
                frame.size.height = height
                tempSearchTable.frame = frame
            }
        }
    }
    
    //Set up the VCModel instances for the callbacks, So that when the variables will set then the appropriate actions can be taken.
    private func setUpModel() {
        
        //set up the alert message closure with an alert.
        vcmodel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.vcmodel.alertMessage {
                    //shows alert with the encountered message.
                    Utilities.showAlert(message: message, owner: self!)
                }
            }
        }
        
        //set up the delay closure, when the delay is encountered
        vcmodel.delayTimeClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let delayTime = self?.vcmodel.delayTime {
                    print("delayTime is :::::::\(delayTime)")
                    //starts the Timer with the encountered delay time.
                    self?.setTimerWithDelay(delay: delayTime)
                }
            }
        }
        
        //set up the challenge closure, when the challenge is encountered.
        vcmodel.showChallengeClosure = {[weak self] (challengeType,challengeValue) in
            DispatchQueue.main.async {
                //calls to handle the challenge.
                self?.handleChallenges(challengeType: challengeType, challengeValue: challengeValue)
            }
        }
        
        //set up the loading closure, when the app is still communication with the server.
        vcmodel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                if let loading = self?.vcmodel.isLoading {
                    //if the loading is set to true
                    if loading {
                        //starts the loader.
                        self?.startLoader()
                    }
                    //if the loading is set to true
                    else {
                        //stops the loader.
                        self?.stopLoader()
                    }
                }
            }
        }
        
        //set up the success response closure, when the communication is successful.
        vcmodel.successFullResponse = { [weak self] (urlType) in
            DispatchQueue.main.async {
                //calls to handle the api request according to the URL type.
                self?.handleAPIs(typeUrl: urlType)
            }
        }
    }
    
    /**
     Sets the Timer, with the delay encountered by the user.
     - Parameter delay: the time the timer needs to be scheduler for a delay.
     */
    private func setTimerWithDelay(delay : Int) {
        //executes when the timer is in invalidate state or not running.
        if !isTimerRunning {
            //starts the timer.
            runTimer(delay: delay)
        }
    }
    
    /**
     Sets up the values/data in the global variables.
     */
    private func setUpData() {
        //gets all the services avalaible in the database.
        services = DBHandler.getServicesData()
        
        //Disable TextField if there is no Service available
        if services.count == 0 {
            textFieldService.isEnabled = false
        } else {
            textFieldService.isEnabled = true
        }
        
        // fill the model, with the services in the rccd files
        model = RCCDLogic(servicesArr: services)
        
        //creates an filtered array of services.
        filteredServices = services
        
        beforeSearchFilteredServices = filteredServices
    }
    
    /**
     Sets up the data/values in the services and username textfield, provided the user have used these values before to authenticate the services.
     */
    private func setUpTextIfAny() {
        let (service,username) = vcmodel.toCheckLastUsedServiceAndUsername()
        if let service = service, let username = username {
            //sets the services textfield with the last used service.
            textFieldService.text = service
            //sets the username textfield with the last used username.
            textFieldUsername.text = username
            //sets the provider icon with the service provide icon.
            setImage()
        }
    }
    /**
     This method returns the point from which the search drop down is started.
     */
    private func getPoint() -> CGPoint {
        return CGPoint(x: textFieldService.frame.origin.x, y: textFieldService.frame.origin.y + textFieldService.frame.size.height)
    }
    
    /**
     Sets up the search table or the services drop down menu , filled with all the services present in the rccd file within the app.
     */
    private func setUpTableServices() {
        //gets the starting point.
        var point = getPoint()
        //height of the drop down menu.
        var calculatedHeight: CGFloat = 0
        
        //rendering for different screen sizes.
        if screenHeight <= 568 {
            point = CGPoint(x: textFieldService.frame.origin.x, y: textFieldService.frame.origin.y - 180)
            calculatedHeight = 180
        }
        else {
            //for bigger devices, the height is calculated.
            calculatedHeight = Utilities.calculateHeightForTable(yOfTable: point.y)
        }
        
        //Creating the drop down menu or table.
        tblSearch = UITableView(frame: CGRect(origin: point, size: CGSize(width: textFieldService.frame.size.width, height: calculatedHeight)), style: .grouped)
        tblSearch?.layer.borderColor = UIColor.lightGray.cgColor
        tblSearch?.separatorStyle = .none
        tblSearch?.layer.borderWidth = 0.5
        tblSearch?.isHidden = true
        tblSearch?.backgroundColor = UIColor.white
        tblSearch?.dataSource = self
        tblSearch?.delegate = self
        tblSearch?.allowsMultipleSelection = false
        
        //sets the drop down menu in the main view.
        self.view.addSubview(tblSearch!)
    }
  
    /**
     This method is used to update the values in the drop down menu , when user enters in the services textfield.
     So searching is done in the database according to the user input , and the matching values or similar values is been updated in the table or menu.
     */
    private func updateValue() {
        //gets the rccd/services values matching with the user input.
        if let rccdArr = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) {
            //removes all the values from the menu.
            filteredServices.removeAll()
            
            //sets new values in the menu array.
            filteredServices = rccdArr
            
            //if any values matches in the database, then the menu will be shown, else will be hidden.
            if filteredServices.count == 0 {
                filteredServices = beforeSearchFilteredServices
                showTable(hidden: true)
            }
            else {
                //shows the table and reload the updated data in the menu.
                showTable(hidden: false)
                tblSearch?.delegate = self
                tblSearch?.reloadData()
            }
        } else {
            //if there is nothing to search, then the table view will gets to its default state.
            
            //sets the services array, with the array value before the searching stage.
            filteredServices = beforeSearchFilteredServices
            
            //presents the table and reload it with the updates data.
            if filteredServices.count == 0 {
                showTable(hidden: true)
            }
            else {
                showTable(hidden: false)
            }
            tblSearch?.delegate = self
            tblSearch?.reloadData()
        }
    }
    
    /**
     This is used to handle the visibility of the drop down menu or table displaying the services.
     */
    private func showTable(hidden: Bool) {
        tblSearch?.isHidden = hidden
    }
    
    /**
     This method is used to check that the username and password textfield can be enabled for the user or not.
     
     - Returns: A bool value, to notify the enabling of the textfield.
     */
    private func canEnabledUserAndPassTextField() -> Bool {
        var isAllow = false
        //gets the values similar to the textfield.if avalaible then the enabling will be allowed.
        guard let rccdArr = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) ,rccdArr.count > 0  else {
            return false
        }
        isAllow = true
        
        return isAllow
    }
    
    /**
     This method is used to enable the username, password textfield and authentication button.
     */
    private func enableTextFieldsAndButton() {
        //checks wheather to enable or not.
        let isAllowed = canEnabledUserAndPassTextField()
        
        //sets the result in the textfields and button.
        textFieldUsername.isUserInteractionEnabled = isAllowed
        textFieldPassword.isUserInteractionEnabled = isAllowed
        btnLogin.isUserInteractionEnabled = isAllowed
    }
    
    /**
     This method will get the service name from the drop down menu or table view.
     - Parameter indexPath: The index for which the service needs to be retrieved.
     - Returns: The service name at the given indexpath.
     */
    private func getService(indexPath: IndexPath) -> String {
        let user = filteredServices[indexPath.section]
        let selectedService = user.Providers[0].Services[indexPath.row]
        return selectedService.Name
    }
    

    /**
     This method is used to handle the api request to the server according to the URL.
     The URL type is used to notify that the server communication is successful for that URL and to call the next sequential server request.
     
     - Parameter typeUrl: Type of URL for server communication.
     */
    private func handleAPIs(typeUrl: URLs) {
        switch typeUrl {
        case .hello:
            //after completing hello communication, calls for handshaking.
            vcmodel.requestForApiService(urlType: .handshake)
        case .handshake:
            //after completing handshaking communication, calls for authentication requirements.
            vcmodel.requestForApiService(urlType: .authReq)
        case .authReq:
            //after completing authentication requirements communication, calls for authentication.
            vcmodel.requestForApiService(urlType: .authentication)
        case .authentication:
            //after completing authentication communication, calls for certificate.
            vcmodel.requestForApiService(urlType: .certificate)
        case .challenge:
            //for completing the challenge encountered by the user
            vcmodel.requestForApiService(urlType: .certificate)
        case .certificate:
            //at last, donwload the certificate after the authentication.
            downloadCertificate()
 
        }
    }
    
    /**
     This method is used to download the certificate after the authentication is completed.
     */
    private func downloadCertificate() {
        //converts the response json data.
        let dict = try! JSONSerialization.jsonObject(with: dataCert, options: []) as? [String:Any]
        
        //gets the status of the response.
        if let status = dict!["status"] as? String {
            //if auth status is cert.
            if status == "cert" {
                //saves the service name and its respective username in the database.
                if let username = textFieldUsername.text , let service = textFieldService.text {
                    //save the username and services name ,after successful authentication.
                    UserDetailsHandler.saveUsernameAndServices(username: username, services: service)
                }
                
                //gets the url from which the certificate needs to be downloaded.
                guard let certUrlStr = dict!["cert-url-templ"] as? String,certUrlStr.count > 0 else{
                    DispatchQueue.main.async {
                        self.resetAll(aServicesArray: false)
                        Utilities.showAlert(message: "Error_occured_communication".localized(KTLocalLang), owner: self)
                    }
                    return
                }
                //proceed to download the certificate from that URL.
                self.proceedForDownloadingCertificate(serverStr: selectedUserModel!.Providers[0].Server,url: certUrlStr)
            }
            else {
                DispatchQueue.main.async {
                    //if failed, then reset the state and pop up is generated.
                    self.resetAll(aServicesArray: false)
                    Utilities.showAlert(message: "Error_occured_communication".localized(KTLocalLang), owner: self)
                }
            }
        }
    }
    
    /**
     This method is used to present the certificate view, when the certificate is to be downloaded.
     A view is presented to the user , which require user interaction inorder to download the certificate from the safari, as the control transfers to the safari.
     
     - Parameter toShow: A bool value, indicating wheather to show the view or not.
     */
    private func certificateAlert(toShow: Bool) {
        let view = self.view.viewWithTag(150)
        view?.isHidden = toShow
    }
    
    /**
     This method is used to reset the view to its default or initial state.
     With all the variables being initialized to its default value.
     
     - Parameter aServicesArray: A bool value, indicating wheather to delete or reset all the services or not.
     */
    func resetAll(aServicesArray: Bool) {
        textFieldService.text = ""
        textFieldPassword.text = ""
        textFieldUsername.text = ""
        showTable(hidden: true)
        Utilities.resetGlobalMemberVariables()

        //if services also needs to be reset.
        if aServicesArray {
            services.removeAll()
            filteredServices.removeAll()
            setUpData()
        }
    }
    
    /**
     This method is used to reset the view to its default or initial state.
     With all the variables being initialized to its default value except textFieldService and textFieldUsername.
     
     - Parameter aServicesArray: A bool value, indicating wheather to delete or reset all the services or not.
     */
    func resetAllAfterAuthenticate(aServicesArray: Bool) {
        textFieldPassword.text = ""
        showTable(hidden: true)
        Utilities.resetGlobalMemberVariables()
        
        //if services also needs to be reset.
        if aServicesArray {
            services.removeAll()
            filteredServices.removeAll()
            setUpData()
        }
    }
    
    /**
     This method is used to download the certificate form the url , and also attach its password on the pasteboard for the user to download and verify the certificate.
     
     - Parameter serverStr: The server value at which the certificate is.
     - Parameter url : The url of the certificate.
     */
    private func proceedForDownloadingCertificate(serverStr: String, url: String) {
        var tempUrlStr = url
        
        //getting the password for the certificate.
        let passcode = keytalkCookie.components(separatedBy: "=")[1]
        let index = passcode.index(passcode.startIndex, offsetBy: 30)
        let subString = passcode[..<index]
        
        //Attaching the certificate password on the pasteboard, so that the user can just paste the password and verify the certificate.
        let pb = UIPasteboard.general
        pb.string = subString.description
        print(UIPasteboard.general.string ?? "")
        
        //creating a valid url withe service host url and the certificate url.
        tempUrlStr = tempUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverStr)
        print(tempUrlStr)
        
        //initializing the certificate url.
        certificateUrl = URL.init(string: tempUrlStr)
        DispatchQueue.main.async {
            self.certificateAlert(toShow: false)
        }
    }
    
    /**
     This method is used to start the loader or activity indicator, during the server commnication.
     */
    private func startLoader() {
        self.view.endEditing(true)
        UIApplication.shared.beginIgnoringInteractionEvents()
        let viewLoader = self.view.viewWithTag(101)
        viewLoader?.isHidden = false
    }
    
    
    /**
     This method is used to stop the loader or activity indicator, when the server commnication is finished.
     */
    private func stopLoader() {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
            let viewLoader = self.view.viewWithTag(101)
            viewLoader?.isHidden = true
        }
    }
    
    /**
     This method is used to update the view, after the rccd file is imported.
     The drop down menu or table will be reloaded with the updated values, and the service textfield will be updated with the latest service from the rccd file.
     */
    func onSuccessfullRccdImport() {
        //gets the first service form the rccd file.
        let strService = filteredServices.last?.Providers[0].Services.first?.Name
        if let strService = strService {
            textFieldService.text = strService
        }
        tblSearch?.reloadData()
    }
    
    /**
     This method is used to download the RCCD file from the given URl and will be unzipped to retrive the contents of the file.
     - Parameter aDownloadUrl: The URL through which the rccd file is downloaded.
     */
    func downloadRccdThroughUrl( aDownloadUrl: String) {
        //gets the valid download URL.
        let urlString = vcmodel.getDownloadURLString(aDownloadStr: aDownloadUrl)
        //initiates the URL.
        let url = URL.init(string: urlString)
        if let url = url {
            //request the server hit, for downloading the rccd file.
            vcmodel.requestForDownloadRCCD(downloadUrl: url) { [unowned self] (localUrl) in
                //localurl represents the system file path at which the rccd file is been downloaded and kept.
                if let localUrl = localUrl {
                    //send the rccd file to unzipped and retrive the contents of the file.
                    Utilities.unzipRCCDFile(url: localUrl, completionHandler: { [weak self] (success) in
                        //if successfully unzipped.
                        if success {
                            DispatchQueue.main.async {
                                //refresh the view with the updated data.
                                self?.refreshData()
                            }
                        } else {
                            //if the RCCD file downloaded is invalid or unable to unzip
                            Utilities.showAlert(message: "invalid_rccd".localized(KTLocalLang), owner: self!)
                        }
                    })
                }
                else {
                    //If the download fails, or the system unables to retrive the local file from the url.
                    Utilities.showAlert(message: "Something_went_wrong".localized(KTLocalLang), owner: self)
                }
            }
        }
        else {
            //if the url entered is empty.
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            Utilities.showAlert(message: "Enter_valid_url".localized(KTLocalLang), owner: (appDel.window?.rootViewController)!)
        }
    }
    
    /**
     This method is used to set the provider icon, in the view.
     The image of the provider , whose service is selected by the user is set.
     */
    private func setImage() {
        guard let serviceEntered = textFieldService.text, serviceEntered.count > 0 else {
            return
        }
        
        //search the services avalaible in the database.
        guard let arrServices = model?.searchArrAccToWriteValue(textToSearch: serviceEntered) , arrServices.count >  0  else {
            return
        }
        //gets the services selected.
        let user = arrServices[0]
        //gets the provider logo, as Image Data, then sets it on the view.
        if let imageData = user.Providers[0].imageLogo {
            imgLogo.image = UIImage.init(data: imageData)
        }
        else {
            imgLogo.image = UIImage.init(named: "icon")
        }
    }
    
    /**
     This method is used, after the User validation.
     */
    private func handleAfterUserAuthenication () {
        DispatchQueue.main.async {
            self.view.viewWithTag(111)?.isHidden = true
            self.setupView()
            self.perform(#selector(self.moveToImportPageIfNoService), with: nil, afterDelay: 0.1)
        }
    }
    
   
    //MARK:- CallBacks
    
    /**
     This is the Callback Method for biometric validation response. When the user will validate itself through biometric validation, then the repsonse or result of the validation will be recieved in this method, and handling is done accordingly.
     
     - Parameter isSuccess: A bool value, indication the success of the validation.
     - Parameter authError: The error object, used to retrive the error message, if any error occurs.
     */
    func getValidationResult(isSuccess: Bool, authError: Error?) {
        if isSuccess {
            //if user validates successfully.
            handleAfterUserAuthenication()
        } else {
            //if user have activated the app lock, but have not registered their biometrics(fingerprint or faceprint) or passcode in the device.
            if authError?.localizedDescription == "Passcode_notset".localized(KTLocalLang) {
                Utilities.showAlert(message: "passcode_configure_alert".localized(KTLocalLang), owner: self) { _  in
                    self.handleAfterUserAuthenication()
                }
            } else {
                //if the user validation fails.
                Utilities.showAlert(message: "Biometric_validation_alert".localized(KTLocalLang), owner: self) { _ in
                self.validateUser()
                }
            }
        }
    }
    
    /**
     This method is used to handle the challenge when the user encounters it.
     
     - Parameter challengeType: Type of challenge encountered.
     - Parameter challengeValue: The Challenge message encountered.
     */
    private func handleChallenges(challengeType:ChallengeResult,challengeValue:String) {
        //sets the name of challenge in a variable
        challengeMessage = challengeValue
        challengeName = ChallengeResult.PassWordChallenge.rawValue
        
        //calls to display the challenge view to the user, to register their response.
        showChallengeView(challengeValue,false)
    }
    
    /**
     This method is used to display the challenge view with the encountered challenge message.
     
     - Parameter message: The challenge message encountered.
     - Parameter toHide: A bool value to indicate the visibility of the challenge View.
     */
    private func showChallengeView(_ message:String,_ toHide:Bool) {
        //makes the challenge view visible to the user.
        self.view.viewWithTag(222)?.isHidden = toHide
        
        var userMessage  = message
        var challengeType : ChallengeType?
        challengeType = ChallengeType.init(rawValue: message)
        if let _challengeType = challengeType {
            switch _challengeType {
            case .nextToken :
                userMessage = "nextToken_string".localized(KTLocalLang)
            case .otp :
                userMessage = "otp_string".localized(KTLocalLang)
            case .newUserDefinedPin :
                userMessage = "newUserDefinedPin_string".localized(KTLocalLang)
            case .reenterNewPin :
                userMessage = "reenterNewPin_string".localized(KTLocalLang)
            case .newPinandPasscode :
                userMessage = "newPinandPasscode_string".localized(KTLocalLang)
            case .newSystemPushedPin :
                userMessage = "newSystemPushedPin_string".localized(KTLocalLang)
            default:
                userMessage = message
            }
        } else {
            
        }
        //sets the challenge message on the view.
        challengeTypeLbl.text = userMessage
    }
    
    /**
     This method is used to dismiss the challenge view, after registering the challenge response from the user.
     */
    private func dismissChallengeView() {
        //sets the view to its default state
        challengeTypeLbl.text = ""
        
        //sets the textfield text to default.
        textFieldChallenge.text = ""
        textFieldChallenge.placeholder = "Enter_your_response".localized(KTLocalLang)
        
        //hides the challenge view.
        self.view.viewWithTag(222)?.isHidden = true
    }
    
    
    //MARK:- Timer handling
    
    /**
     This method is used to handle the view when the delay is encountered.
     in this the timer will be updated and the view will be updated accordingly.
     */
    private func handleAfterDelay(_ isTimerStarted:Bool) {
        //if timer is  already started.
        if isTimerStarted {
            if delayTimeInSeconds > 0 {
                //This will decrement(count down)the seconds.
                delayTimeInSeconds -= 1
                //disable the authentication button.
                setLoginBtn(true)
            } else {
                //stops the timer.
                timer.invalidate()
                timer = Timer()
                isTimerRunning = false
                self.delayTimeInSeconds = 0
                
                //enables the authentication button.
                setLoginBtn(false)
            }
        } else {
            setLoginBtn(false)
        }
        
    }
    
    /**
     This will enable the authentication button, according to the working of the timer.
     - Parameter isWaiting: A bool value, indication the running of the timer.
     */
    private func setLoginBtn(_ isWaiting:Bool) {
        if isWaiting {
            //if the timer is running, then the button will be disabled, and updated with the delay time left.
            btnLogin?.isEnabled = false
            btnLogin?.titleLabel?.textAlignment = .center
            btnLogin?.titleLabel?.text = "\("Delay_wait".localized(KTLocalLang)) \(delayTimeInSeconds)s"
        } else {
            //if timer is stopped or invalidate, then the button will be enabled.
            btnLogin?.isEnabled = true
            btnLogin?.titleLabel?.text = "Authenticate_string".localized(KTLocalLang)
        }
    }
    
    /**
     This method is used to schedule the Timer with time duration equal to the delay time encountered.
     - Parameter delay: The time duration for which the timer needs to be scheduled.
     */
    private func runTimer(delay : Int) {
        //global value is set.
        self.delayTimeInSeconds = delay
        
        //checks , wheather timer is running or not.
        if isTimerRunning == false {
            isTimerRunning = true
            DispatchQueue.main.async {
                self.timer.invalidate()
                //schedules the timer with the delay time duration.
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
            }
        }
    }
    
    /**
     This method check , wheather the timer should be continued or not.
     In this when a user encounters a delay for a particular service, then the timer will be scheduled, but they can still use other services other than the one which got delay as a response. So  for other services, timer should not be continued.
     */
    private func shouldTimerContinue() {
        //checks, if the previous selected and current selected service matches.
        if currentSelectedService == lastSelectedService {
            //if matches, then timer should continue.
            setLoginBtn(isTimerRunning)
        } else {
            //if not, then timer is stopped.
            if isTimerRunning {
                isTimerRunning = false
                setLoginBtn(isTimerRunning)
            }
        }
    }
    
    
    // MARK:-Delegate and DataSource Drop Down Table/Menu
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredServices.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = filteredServices[section]
        return value.Providers[0].Services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.textLabel?.textColor = UIColor.init(hexString: "#676765")
        cell.textLabel?.text = getService(indexPath: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        comingFromDidSelect = true
        tblSearch?.isHidden = true
        textFieldService.text = getService(indexPath: indexPath)
        currentSelectedService = textFieldService.text!
        shouldTimerContinue()
        setImage()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //sets the header view of the cell.
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        //sets the icon for the provider.
        let imgView = UIImageView(frame: CGRect(x: 5, y: 11, width: 30, height: 30))
        imgView.contentMode = .scaleAspectFit
        let user = filteredServices[section]
        if let imageData = user.Providers[0].imageLogo {
            imgView.image = UIImage.init(data: imageData)
        }
        else {
            imgView.image = UIImage.init(named: "icon")
        }
        viewHeader.addSubview(imgView)
        
        //sets the  header label for the provider .
        let lblTblHeader = UILabel(frame: CGRect(x: imgView.frame.origin.x + imgView.frame.size.width, y: 0, width: tableView.frame.size.width - 60, height: 50))
        lblTblHeader.textColor = UIColor.init(hexString: "#676765")
        lblTblHeader.font = UIFont.boldSystemFont(ofSize: 20)
        lblTblHeader.text = "  " + user.LatestProvider
        viewHeader.addSubview(lblTblHeader)
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let serviceText = textField.text {
            currentSelectedService = serviceText
            shouldTimerContinue()
        }
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == textFieldService {
            if let service = textFieldService.text {
                if service.count == 0 && filteredServices.count > 0 {
                    textFieldService.text = filteredServices[0].Providers[0].Services[0].Name
                }
                textFieldUsername.text = UserDetailsHandler.getUsername(for: service)
                if let user = UserDetailsHandler.getLastSavedEntry() {
                    if user.service == textFieldService.text{
                        textFieldUsername.text = user.username
                    }
                }
                setImage()
                showTable(hidden: true)
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == textFieldService {
            textFieldService.text = ""
            textFieldUsername.text = ""
            textFieldPassword.text = ""
            if services.count > 0 {
                showTable(hidden: false)
            }
        }
        else {
            showTable(hidden: true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    // MARK:- Actions
    @IBAction func loginTapped(sender: UIButton) {
        //searchs the selected or entered service name in the database.
        guard let userModel = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) else {
//            let service_match_alert = NSLocalizedString("service_match_alert", tableName: nil, bundle: languageSelected, value: nil, comment: "")
            Utilities.showAlert(message: "service_match_alert".localized(KTLocalLang), owner: self)
            return
        }
        
        //gets the username , password and services from the user input.
        if let user = textFieldUsername.text, let pass = textFieldPassword.text, let service = textFieldService.text {
            //validate the user response.
            if user.count > 0 && pass.count > 0 && service.count > 0 {
                selectedUserModel = userModel[0]
                username = user
                password = pass
                
                //gets the service url.
                let serviceUrl = Utilities.returnValidServerUrl(urlStr: selectedUserModel!.Providers[0].Server)
                serverUrl = serviceUrl
                serviceName = service
                lastSelectedService = service
                //request for the hello server communication, with the input credentials.
                vcmodel.requestForApiService(urlType: .hello)
                
            }
            else {
                Utilities.showAlert(message: "Enter_details_alert".localized(KTLocalLang), owner: self)
            }
        }
    }

    
    @IBAction func tapGesture(gesture: UITapGestureRecognizer) {
        if let tempTable = tblSearch {
            if !tempTable.isHidden && !textFieldService.isEditing {
                tempTable.isHidden = true
            }
        }
        guard let serviceSearched = textFieldService.text , serviceSearched.count > 0 else {
            filteredServices = beforeSearchFilteredServices
            return
        }
    }
    
    /**
     Action method, when he user interats with the certificate alert view, inorder to move to safari to download the certificate.
     */
    @IBAction func okClickedCertificateAlert() {
        certificateAlert(toShow: true)
        self.resetAllAfterAuthenticate(aServicesArray: false)
        UIApplication.shared.open(certificateUrl, options: [:], completionHandler: nil)
    }
    
    
    /**
        This is the Action method used to download the primary or root and secondary certificated, from the safari.
     */
    @IBAction func downloadCertificates(sender: UIButton) {
        
        //validate the user input.
        guard let selectedService = textFieldService.text , selectedService.count > 0 else {
            Utilities.showAlert(message: "Select_service_alert".localized(KTLocalLang), owner: self)
            return
        }
        
        //checks the avalaibility of the service selected in the database.
        guard let rccdArr = model?.searchArrAccToWriteValue(textToSearch: selectedService), rccdArr.count > 0 else {
            Utilities.showAlert(message: "Select_service_alert".localized(KTLocalLang), owner: self)
            return
        }
        
        //gets the server url.
        let serverStr = rccdArr[0].Providers[0].Server
        let actionSheet = UIAlertController(title: "KeyTalk", message: "Download_one_by_one".localized(KTLocalLang), preferredStyle: .actionSheet)
        //adds action to download primary certificate.
        let primaryCerAction = UIAlertAction(title: "Root_certificate".localized(KTLocalLang), style: .default) { (action) in
            let url = URL(string: "https://\(serverStr)\(caPort)/ca/1.0.0/primary")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
        //adds action to download secondary certificate.
        let secondaryCerAction = UIAlertAction(title: "secondary_certificate_string".localized(KTLocalLang), style: .default) { (action) in
            let url = URL(string: "https://\(serverStr)\(caPort)/ca/1.0.0/signing")
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }
        //adds cancel button.
        let cancel = UIAlertAction(title: "Cancel_string".localized(KTLocalLang), style: .destructive, handler: nil)
        
        actionSheet.addAction(primaryCerAction)
        actionSheet.addAction(secondaryCerAction)
        actionSheet.addAction(cancel)
        
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.present(actionSheet, animated: true, completion: nil)
        //presents the view to the user.
        //self.present(actionSheet, animated: true, completion: nil)
    }
    
    //The Action method to register the user response to complete the challenges.
    @IBAction func challengeOkClicked(_ sender: Any) {
        
        //validate the user response.
        guard let userResponse = textFieldChallenge.text , userResponse.count > 0 else {
            Utilities.showAlert(message: "validate_user_response".localized(KTLocalLang), owner: self)
            return
        }
        
        //creating the response array.
        var arrResponse = [[String:Any]]()
        
        //sets the challeneg name and its corresponding value in the key value pair format.
        var dict : [String:Any] = [String:Any]()
        dict[challengeMessage] = userResponse

        //appending in the response array.
        arrResponse.append(dict)
        challengeResponseArr = arrResponse

        //calls for challenge authentication.
        vcmodel.requestForApiService(urlType: .challenge)
        
        //dismiss the view, after getting the challenge response.
        dismissChallengeView()
        
    }
}
//function to convert the localized text according to the user selected language
extension String {
    func localized(_ lang:String) ->String {

        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }}
