//
//  ViewController.swift
//  KeyTalk
//
//  Created by Paurush on 5/15/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var textFieldService: UITextField!
    @IBOutlet var textFieldUsername: UITextField!
    @IBOutlet var textFieldPassword: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var imgLogo: UIImageView!
    
    var selectedUserModel: UserModel?
    var tblSearch: UITableView?
    var comingFromDidSelect = false
    
    // Services array
    var services = [UserModel]()
    var filteredServices = [UserModel]()
    
    // Models
    var model: RCCDLogic?
    let vcmodel = VCModel()
    
    var certificateUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.perform(#selector(moveToImportPageIfNoService), with: nil, afterDelay: 1.0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        showTable(hidden: true)
    }
    
    @objc private func moveToImportPageIfNoService() {
        if DBHandler.getServicesData().count == 0 {
            self.performSegue(withIdentifier: "importRCCD", sender: nil)
        }
    }
    
    func refreshData() {
        setUpData()
        onSuccessfullRccdImport()
    }
    
    // MARK:- Private
    private func addEventOnTextFieldService() {
        textFieldService.addTarget(self, action: #selector(textChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    
    private func setupView() {
        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
        setupKeyboardHack()
        setUpModel()
        setUpData()
        setUpTableServices()
        setUpTextIfAny()
        addEventOnTextFieldService()
    }
    
    private func setupKeyboardHack() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        ///// WorkAround to get height of keyboard
        let field = UITextField()
        UIApplication.shared.windows.last?.addSubview(field)
        field.becomeFirstResponder()
        field.resignFirstResponder()
        field.removeFromSuperview()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let tempKeyboardHeight = keyboardRectangle.height
            keyBoardHeight = tempKeyboardHeight
            updateTableHeight(height: Utilities.calculateHeightForTable(yOfTable: getPoint().y))
        }
    }
    
    func updateTableHeight(height: CGFloat) {
        if let tempSearchTable = tblSearch {
            if screenHeight > 568 {
                var frame = tempSearchTable.frame
                frame.size.height = height
                tempSearchTable.frame = frame
            }
        }
    }
    
    private func setUpModel() {
        vcmodel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.vcmodel.alertMessage {
                    Utilities.showAlert(message: message, owner: self!)
                }
            }
        }
        
        vcmodel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                if let loading = self?.vcmodel.isLoading {
                    if loading {
                        self?.startLoader()
                    }
                    else {
                        self?.stopLoader()
                    }
                }
            }
        }
        
        vcmodel.successFullResponse = { [weak self] (urlType) in
            DispatchQueue.main.async {
                self?.handleAPIs(typeUrl: urlType)
            }
        }
    }
    
    private func setUpData() {
        services = DBHandler.getServicesData()
        model = RCCDLogic(servicesArr: services)
        filteredServices = services
    }
    
    private func setUpTextIfAny() {
        let (service,username) = vcmodel.toCheckLastUsedServiceAndUsername()
        if let service = service, let username = username {
            textFieldService.text = service
            textFieldUsername.text = username
            setImage()
        }
    }
    
    func getPoint() -> CGPoint {
        return CGPoint(x: textFieldService.frame.origin.x, y: textFieldService.frame.origin.y + textFieldService.frame.size.height)
    }
    
    private func setUpTableServices() {
        var point = getPoint()
        var calculatedHeight: CGFloat = 0
        
        if screenHeight <= 568 {
            point = CGPoint(x: textFieldService.frame.origin.x, y: textFieldService.frame.origin.y - 180)
            calculatedHeight = 180
        }
        else {
            calculatedHeight = Utilities.calculateHeightForTable(yOfTable: point.y)
        }
        
        tblSearch = UITableView(frame: CGRect(origin: point, size: CGSize(width: textFieldService.frame.size.width, height: calculatedHeight)), style: .grouped)
        tblSearch?.layer.borderColor = UIColor.lightGray.cgColor
        tblSearch?.separatorStyle = .none
        tblSearch?.layer.borderWidth = 0.5
        tblSearch?.isHidden = true
        tblSearch?.backgroundColor = UIColor.white
        tblSearch?.dataSource = self
        tblSearch?.delegate = self
        tblSearch?.allowsMultipleSelection = false
        self.view.addSubview(tblSearch!)
    }
    
    @objc private func textChanged(textField: UITextField) {
       /* if comingFromDidSelect {
            comingFromDidSelect = false
        }
        else {
            updateValue()
            
        }*/
        updateValue()
    }
    
    private func updateValue() {
        
        guard let rccdArr = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) else {
            return
        }
        filteredServices.removeAll()
        filteredServices = rccdArr
        
        if filteredServices.count == 0 {
            showTable(hidden: true)
        }
        else {
            showTable(hidden: false)
            tblSearch?.reloadData()
            tblSearch?.delegate = self
            //enableTextFieldsAndButton()
        }
    }
    
    private func showTable(hidden: Bool) {
        tblSearch?.isHidden = hidden
    }
    
    private func canEnabledUserAndPassTextField() -> Bool {
        
        guard let rccdArr = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) else {
            return false
        }
        var isAllow = false
        
        if rccdArr.count > 0 {
            isAllow = true
        }
        return isAllow
    }
    
    private func enableTextFieldsAndButton() {
        let isAllowed = canEnabledUserAndPassTextField()
        textFieldUsername.isUserInteractionEnabled = isAllowed
        textFieldPassword.isUserInteractionEnabled = isAllowed
        btnLogin.isUserInteractionEnabled = isAllowed
    }
    
    private func getService(indexPath: IndexPath) -> String {
        let user = filteredServices[indexPath.section]
        let selectedService = user.Providers[0].Services[indexPath.row]
        return selectedService.Name
    }
    
    private func handleAPIs(typeUrl: URLs) {
        switch typeUrl {
        case .hello:
            vcmodel.requestForApiService(urlType: .handshake)
        case .handshake:
            vcmodel.requestForApiService(urlType: .authReq)
        case .authReq:
            vcmodel.requestForApiService(urlType: .authentication)
        case .authentication:
            vcmodel.requestForApiService(urlType: .certificate)
        case .certificate:
            downloadCertificate()
        default:
            print("\(typeUrl) not handled")
        }
    }
    
    private func downloadCertificate() {
        let dict = try! JSONSerialization.jsonObject(with: dataCert, options: []) as? [String:Any]
        
        if let status = dict!["status"] as? String {
            if status == "cert" {
                if let username = textFieldUsername.text , let service = textFieldService.text {
                    UserDetailsHandler.saveUsernameAndServices(username: username, services: service)
                }
                
                let certUrlStr = dict!["cert-url-templ"] as! String
                if certUrlStr.count > 0 {
                    self.proceedForDownloadingCertificate(serverStr: selectedUserModel!.Providers[0].Server,url: certUrlStr)
                }
            }
            else {
                DispatchQueue.main.async {
                    //self.stopLoader()
                    self.resetAll(aServicesArray: false)
                    Utilities.showAlert(message: "Error occurred in communication", owner: self)
                }
            }
        }
    }
    
    private func certificateAlert(toShow: Bool) {
        let view = self.view.viewWithTag(150)
        view?.isHidden = toShow
    }
    
    func resetAll(aServicesArray: Bool) {
        textFieldService.text = ""
        textFieldPassword.text = ""
        textFieldUsername.text = ""
        showTable(hidden: true)
        Utilities.resetGlobalMemberVariables()
        if aServicesArray {
            services.removeAll()
            filteredServices.removeAll()
        }
    }
    
    private func proceedForDownloadingCertificate(serverStr: String, url: String) {
        var tempUrlStr = url
        
        let passcode = keytalkCookie.components(separatedBy: "=")[1]
        let index = passcode.index(passcode.startIndex, offsetBy: 30)
        let subString = passcode[..<index]
        
        let pb = UIPasteboard.general
        pb.string = subString.description
        print(UIPasteboard.general.string ?? "")
        
        tempUrlStr = tempUrlStr.replacingOccurrences(of: "$(KEYTALK_SVR_HOST)", with: serverStr)
        print(tempUrlStr)
        
        certificateUrl = URL.init(string: tempUrlStr)
        DispatchQueue.main.async {
            self.certificateAlert(toShow: false)
        }
    }
    
    private func startLoader() {
        self.view.endEditing(true)
        UIApplication.shared.beginIgnoringInteractionEvents()
        let viewLoader = self.view.viewWithTag(101)
        viewLoader?.isHidden = false
    }
    
    private func stopLoader() {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
            let viewLoader = self.view.viewWithTag(101)
            viewLoader?.isHidden = true
        }
    }
    
    func onSuccessfullRccdImport() {
        let strService = filteredServices.last?.Providers[0].Services.first?.Name
        if let strService = strService {
            textFieldService.text = strService
        }
        tblSearch?.reloadData()
    }
    
    func downloadRccdThroughUrl( aDownloadUrl: String) {
        let urlString = vcmodel.getDownloadURLString(aDownloadStr: aDownloadUrl)
        let url = URL.init(string: urlString)
        if let url = url {
            vcmodel.requestForDownloadRCCD(downloadUrl: url) { [unowned self] (localUrl) in
                if localUrl != nil {
                    Utilities.unzipRCCDFile(url: localUrl!, completionHandler: { [weak self] (success) in
                        if success {
                            DispatchQueue.main.async {
                                self?.refreshData()
                            }
                        }
                    })
                }
                else {
                    Utilities.showAlert(message: "Something went wrong.", owner: self)
                }
            }
        }
        else {
            let appDel = UIApplication.shared.delegate as! AppDelegate
            Utilities.showAlert(message: "Please enter valid url.", owner: (appDel.window?.rootViewController)!)
        }
    }
    
    private func setImage() {
        if textFieldService.text!.count > 0 {
            if let arrServices = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text!) {
                if arrServices.count > 0 {
                    let user = arrServices[0]
                    if let imageData = user.Providers[0].imageLogo {
                        imgLogo.image = UIImage.init(data: imageData)
                    }
                    else {
                        imgLogo.image = UIImage.init(named: "icon")
                    }
                }
            }
        }
    }
    
    // MARK:- DataSource Table
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
        setImage()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
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
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == textFieldService {
            if let service = textFieldService.text {
                textFieldUsername.text = UserDetailsHandler.getUsername(for: service)
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
//            if textField == textFieldUsername {
//                if let service = textFieldService.text {
//                    textField.text = UserDetailsHandler.getUsername(for: service)
//                }
//            }
            showTable(hidden: true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    // MARK:- Actions
    @IBAction func loginTapped(sender: UIButton) {
        guard let userModel = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) else {
            Utilities.showAlert(message: "Service doesn't match with given services", owner: self)
            return
        }
        
        if let user = textFieldUsername.text, let pass = textFieldPassword.text, let service = textFieldService.text {
            if user.count > 0 && pass.count > 0 && service.count > 0 {
                selectedUserModel = userModel[0]
                username = user
                password = pass
                //UserDetailsHandler.saveUsernameAndServices(username: username, services: service)
                let serviceUrl = Utilities.returnValidServerUrl(urlStr: selectedUserModel!.Providers[0].Server)
                serverUrl = serviceUrl
                serviceName = textFieldService.text!
                vcmodel.requestForApiService(urlType: .hello)
                
            }
            else {
                Utilities.showAlert(message: "Please enter all details", owner: self)
            }
        }
    }

    @IBAction func tapGesture(gesture: UITapGestureRecognizer) {
        if let tempTable = tblSearch {
            if !tempTable.isHidden && !textFieldService.isEditing {
                tempTable.isHidden = true
            }
        }
    }
    
    @IBAction func okClickedCertificateAlert() {
        certificateAlert(toShow: true)
        self.resetAll(aServicesArray: false)
        UIApplication.shared.open(certificateUrl, options: [:], completionHandler: nil)
    }
    
    @IBAction func downloadCertificates(sender: UIButton) {
        
        guard let rccdArr = model?.searchArrAccToWriteValue(textToSearch: textFieldService.text) else {
            return
        }
        
        if textFieldService.text!.count == 0 || rccdArr.count == 0 {
            Utilities.showAlert(message: "Please select KeyTalk service for downloading certificate chain.", owner: self)
        }
        else {
            let serverStr = rccdArr[0].Providers[0].Server
            let actionSheet = UIAlertController(title: "KeyTalk", message: "Download certificates one by one", preferredStyle: .actionSheet)
            let primaryCerAction = UIAlertAction(title: "Root Certificate", style: .default) { (action) in
                let url = URL(string: "http://\(serverStr):8000/ca/1.0.0/primary")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }
            let secondaryCerAction = UIAlertAction(title: "Secondary Certificate", style: .default) { (action) in
                let url = URL(string: "http://\(serverStr):8000/ca/1.0.0/signing")
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            actionSheet.addAction(primaryCerAction)
            actionSheet.addAction(secondaryCerAction)
            actionSheet.addAction(cancel)
            
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
}

