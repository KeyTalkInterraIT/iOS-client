//
//  ImportVC.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import UIKit
import MessageUI


class ImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    @IBOutlet var tblSettings: UITableView!
    @IBOutlet var viewAbout: UIView!
    @IBOutlet var lblVersion: UILabel!
    @IBOutlet weak var lblAboutDetails: UILabel!
    @IBOutlet weak var lblHeadImportConfiguration: UILabel!
    @IBOutlet weak var okAboutButton: UIButton!
    @IBOutlet weak var pickerViewLang: UIPickerView!
    
    var allLanguages = ["English", "German", "French", "Dutch"]
    
    //MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerViewLang.showsSelectionIndicator = true
        pickerViewLang.backgroundColor = UIColor.init(white: 1, alpha: 1)
        pickerViewLang.isHidden = true
        
        pickerViewLang.dataSource = self
        pickerViewLang.delegate = self
        
        
        
        //sets the app version
        lblVersion.text = "Version:".localized(KTLocalLang) + Utilities.getVersionNumber()+"(\(Utilities.getBuildNumber()))"
        
        //Rendering the view, for iphoneX
        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblHeadImportConfiguration.text = "import_config".localized(KTLocalLang)
        lblAboutDetails.text = "about_details".localized(KTLocalLang)
        okAboutButton.setTitle("ok_string".localized(KTLocalLang), for: .normal)
    }
    
    // MARK: UITableView Datasource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.row == 0 {
            //sets the cell with import type cell, at index 0.
            cell = getImportCell()
        }
        else if indexPath.row == 1 {
            //sets the cell with applock type cell, at index 1.
            cell = getAppLockCell()
        }
        else if indexPath.row == 2 || indexPath.row == 3 {
            //sets the cell with report type cell, at index 2.
            //sets the cell with remove configuration type cell, at index 3.
            cell = getReportCell(index: indexPath.row)
        }
        //        else {
        //            //sets the cell with client identifier type cell, at index 4.
        //            cell = getIdentifierCell()
        //        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //cell height object.
        var height: CGFloat = 0
        
        //sets the cell height  according to the cell index
        if indexPath.row == 0 {
            height = 310
        }else if indexPath.row == 1 {
            height = 50
        }
            //        else if indexPath.row == 4 {
            //            height = 200
            //        }
        else {
            height = 120
        }
        
        return height
    }
    
    // MARK: Private Methods
    
    /**
     This funtions creates a tableview cell of type ImportCell.
     
     - Returns: a UITableViewCell of type ImportCell.
     */
    private func getImportCell() -> UITableViewCell {
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "importCell") as? ImportCell
        if let i_cell = cell {
            
            i_cell.lblHeading.text = "lblimportCellHead".localized(KTLocalLang)
            i_cell.lblSubHeading.text = "lblimportCellSubheading".localized(KTLocalLang)
            i_cell.btnShowMeHow.setTitle("show_me_how".localized(KTLocalLang), for: .normal)
            i_cell.textFieldUrl.placeholder = "url_placeholder".localized(KTLocalLang)
            i_cell.btnImport.setTitle("import_string".localized(KTLocalLang), for: .normal)
            i_cell.btnlangchange.setTitle("lang_change".localized(KTLocalLang), for: .normal)
            //sets the tag on the import button
            i_cell.btnImport.tag = 0
            
            //sets the target/action method named'cellAction' on the import button.
            i_cell.btnImport.addTarget(self, action: #selector(cellAction(sender:)), for: .touchUpInside)
            i_cell.btnlangchange.addTarget(self, action: #selector(langAction(sender:)), for: .touchUpInside)
            
            return i_cell
            
        } else {
            return cell!
        }
    }
    
    /**
     This funtions creates a tableview cell of type AppLockCell.
     
     - Returns: a UITableViewCell of type AppLockCell.
     */
    private func getAppLockCell() -> UITableViewCell {
        
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "appLockCell") as? AppLockCell
        
        if let al_cell = cell {
            al_cell.lAppunlock.text = "app_unlock".localized(KTLocalLang)
            //gets the bool value from the userDefaults , indicating the AppLockState of the app
            if let isOn = UserDefaults.standard.value(forKey: "appLockState") as? Bool {
                //sets the state of the switch.
                al_cell.appLockSwitch.isOn = isOn
            } else {
                //sets the state of the switch to false, incase there is no value for the AppLockState in the UserDefaults.
                al_cell.appLockSwitch.isOn = false
            }
            
            //sets the apperance of the switch.
            al_cell.appLockSwitch.tintColor = UIColor.lightGray
            
            //sets the target/action named 'appLockSwitchValueChanged' to the switch.
            al_cell.appLockSwitch.addTarget(self, action: #selector(appLockSwitchValueChanged(sender:)), for: .valueChanged)
            
            return al_cell
            
        } else {
            return cell!
        }
    }
    
    /**
     This funtions creates a tableview cell of type ReportCell.
     It generated two types of cell, first with Report Button and the other with the Remove Button.
     
     - Returns: a UITableViewCell of type ReportCell.
     */
    private func getReportCell(index: Int) -> UITableViewCell {
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "rrCell") as? ReportAndRemoveCell
        if let r_cell = cell {
            if index == 2 {
                //sets the contents for Send Report functionality
                r_cell.lblHeading.text = "lblHeading1".localized(KTLocalLang)
                r_cell.btnReportAndRemove.setTitle("r_cell_title1".localized(KTLocalLang), for: .normal)
            }
            else {
                //sets the contents for Remove Configuration functionality
                r_cell.lblHeading.text = "lblHeading2".localized(KTLocalLang)
                r_cell.btnReportAndRemove.setTitle( "r_cell_title2".localized(KTLocalLang), for: .normal)
            }
            
            //sets the tag equal to the index of the cell on the report/remove button.
            r_cell.btnReportAndRemove.tag = index
            //sets the target/action method named 'cellAction' on the report/remove button.
            r_cell.btnReportAndRemove.addTarget(self, action: #selector(cellAction(sender:)), for: .touchUpInside)
            
            return r_cell
            
        } else {
            return cell!
        }
    }
    
    /**
     This funtions creates a tableview cell of type ClientIdentifierCell.
     It generates a cell, which contains the information of the device UDID.
     
     - Returns: a UITableViewCell of type ClientIdentifierCell.
     */
    //    private func getIdentifierCell() -> UITableViewCell {
    //        let cell = tblSettings.dequeueReusableCell(withIdentifier: "identifierCell") as? ClientIdentifierCell
    //        if let c_cell = cell {
    //
    //            c_cell.lblClientIdentifier.text = "client_identifier".localized(KTLocalLang)
    //            c_cell.lvlClientIdentifierDetail.text = "client_identifier_detail".localized(KTLocalLang)
    //
    //            //string object,contains the UDID information
    //            if let UDID = KMOpenUDID.value() {
    //                //sets the contents of the cell , with the UDID information
    //                c_cell.lblUDID.text = UDID
    //            } else {
    //                c_cell.lblUDID.text = ""
    //            }
    //
    //            return c_cell
    //        } else {
    //            return cell!
    //        }
    //    }
    
    // MARK:- UIPickerView Delegates and DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allLanguages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //adds TapGesture for language picker
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(pickertapped(gestureRecognizer:)))
        view.addGestureRecognizer(TapGesture)
        //pass the selected value of picker for localization
        languageValue(indexValue: row)
    }
    
    func languageValue(indexValue: Int){
        //To display the language selection to the user for confirmation
        let languageSelected = allLanguages[indexValue]
        Utilities.showAlertWithCancel(message: "\("language_selection_alert".localized(KTLocalLang)) \(languageSelected)", owner: self, completionHandler: {(onselectedlang) in
            if onselectedlang {
                //set the value to variable according to the picker selection
                if indexValue == 0 {
                    KTLocalLang = "en"
                }
                else if indexValue == 1 {
                    KTLocalLang = "de"
                }
                else if indexValue == 2 {
                    KTLocalLang = "fr"
                }
                else if indexValue == 3 {
                    KTLocalLang = "nl"
                }
                //hiding the picker if Selection is confirmed
                self.pickerViewLang.isHidden = true
                //saving the selected value of language
                Utilities.saveLocalCode(language: KTLocalLang)
                //sets the contents for About page
                self.lblHeadImportConfiguration.text = "import_config".localized(KTLocalLang)
                self.lblAboutDetails.text = "about_details".localized(KTLocalLang)
                self.okAboutButton.setTitle("ok_string".localized(KTLocalLang), for: .normal)
                //reloads the data of application after language selection
                self.tblSettings.reloadData()
            }
        })
    }
    
    //MARK:- Objc Methods
    
    /**
     This is the target/action method for the applock switch in the AppLockCell.
     
     - Parameter sender: the UISwitch with outlet appLockSwitch in the AppLockCell
     */
    @objc func appLockSwitchValueChanged(sender : UISwitch) {
        let toggled = sender.isOn
        //sets the state of the switch
        sender.setOn(!toggled, animated: true)
        //save the switch state locally with a key.
        UserDefaults.standard.set(!toggled, forKey: "appLockState")
    }
    
    // After selecting Picker language, to tap anywhere to disapper the picker
    @objc func pickertapped(gestureRecognizer: UITapGestureRecognizer) {
        pickerViewLang.isHidden = true
    }
    
    /**
     This is the action method for picker to appear for selection of language
     - Parameter sender: is of type UIButton
     */
    @objc func langAction(sender: UIButton) {
        //adding language picker to the UIView
        pickerViewLang.isHidden = false
        view.addSubview(pickerViewLang)
    }
    
    /**
     This is the target/action method for the import, remove and report button, differentiated on the basis of the tag assigned to them.
     
     - Parameter sender: is of type UIButton
     */
    @objc func cellAction(sender: UIButton) {
        // if the button tag is 0 i.e import Button
        if sender.tag == 0 {
            
            let indexPath = IndexPath.init(row: 0, section: 0)
            let cell = tblSettings.cellForRow(at: indexPath) as? ImportCell
            
            if let i_cell = cell {
                //fetches the user input from the textfield. i.e url required for importing rccd file
                if let text = i_cell.textFieldUrl.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    //validate the contents of the textfield.
                    if text.count > 0 {
                        //convert that user input into an url.
                        let url = URL.init(string: text)
                        if let _ = url {
                            //start downloading the rccd file from the input url.
                            downloadRccdThroughUrl(aDownloadUrl: text)
                        }
                        else {
                            //when the user entered an invalid url
                            i_cell.textFieldUrl.text = ""
                            //shows the desired pop up to the user.
                            Utilities.showAlert(message: "Enter_valid_url".localized(KTLocalLang), owner: self)
                        }
                    }
                    else {
                        //shows the desired pop up to the user, when the textfield is empty.
                        Utilities.showAlert(message: "Enter_empty_url".localized(KTLocalLang), owner: self)
                    }
                }
            } else{
                Utilities.showAlert(message: "Something_wrong_happened".localized(KTLocalLang), owner: self)
            }
        }
        else if sender.tag == 2 {
            // if the button tag is 2 i.e report Button
            //open the mail composer for the user to send their report.
            openMailComposer()
        }
        else if sender.tag == 3 {
            // if the button tag is 3 i.e Remove Button
            //Shows a warning pop up to the user, before deleting the app data.
            Utilities.showAlertWithCancel(message: "Delete_all_date_confirmation".localized(KTLocalLang), owner: self, completionHandler: { (success) in
                //This executes when user agrees or press OK to delete all the app data.
                if success {
                    // Deletes all the data from the database
                    Utilities.deleteAllDataFromDB()
                    //object for appDelegate
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    //sets the mainScreen or the ServicesScreen as the rootViewController,since all the data have been deleted.
                    let vc = appDelegate.window?.rootViewController as? ViewController
                    if let tempVC = vc {
                        if  tempVC.isKind(of: ViewController.self) {
                            //Resets the Mainscreen or servicesScreen into its default state.
                            tempVC.resetAll(aServicesArray: true)
                        }
                    }
                }
            })
        }
    }
    
    /**
     This funtion is executed to download a rccd file through an url.
     
     - Parameter aDownloadUrl:  Url of the rccd file for downloading, in the string format.
     */
    private func downloadRccdThroughUrl( aDownloadUrl: String) {
        //object for appDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //gets the rootViewController instance
        let vc = appDelegate.window?.rootViewController as? ViewController
        if let tempVC = vc {
            if  tempVC.isKind(of: ViewController.self) {
                //Dismiss the current view, and move to the root view.
                self.dismiss(animated: true, completion: nil)
                //to download the rccd with the input Url.
                tempVC.downloadRccdThroughUrl(aDownloadUrl: aDownloadUrl)
            }
        }
    }
    
    /**
     This funtion is will open the mail composer for the user to send their report to Keytalk Support.
     */
    private func openMailComposer() {
        //object for the mail composer view.
        let mailComposer = MFMailComposeViewController()
        //sets the delegate
        mailComposer.mailComposeDelegate = self
        
        //sets the recipients
        //mailComposer.setToRecipients(["support@keytalk.com"])
        
        //sets the subject of the mail with a predefined value.
        mailComposer.setSubject(EMAIL_REPORT_SUBJECT)
        //creates the body of the report mail.
        let body = "<html><body>\(EMAIL_REPORT_HTML)</html></body>"
        //sets the body of the mail.
        mailComposer.setMessageBody(body, isHTML: true)
        //object for the attachment, with system info and log.
        let attachmentData = HWSIGCheck.systemInfo() + Log.queryLog()
        //object for the attachment, in Data format with utf8 encoding.
        let data = attachmentData.data(using: .utf8)
        if let data = data {
            //adds the attachment data.
            mailComposer.addAttachmentData(data, mimeType: "text/plain", fileName: "client.log")
        }
        //shows the mailcomposer view.
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    //MARK:- Mail Composer Delegate Method.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action Methods
    
    /**
     To Dismiss the current view.
     */
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    /**
     Action Method when the info button is clicked, and ShowMeHow View is displayed.
     */
    @IBAction func infoClicked() {
        viewAbout.isHidden = false
    }
    
    /**
     To dismiss the ShowMeHow View.
     */
    @IBAction func okClicked() {
        viewAbout.isHidden = true
    }
    
    /**
     Action Method when the user clicks the 'know more' button.
     The user is moved to the safari and https://www.keytalk.com is opened in the safari
     */
    @IBAction func urlClicked() {
        //url object is created
        let url = URL.init(string: "https://www.keytalk.com")
        let application = UIApplication.shared
        //to move the user to safari with the keytalk url.
        if application.canOpenURL(url!) {
            //about View is hidden and url is been opened in the safari.
            viewAbout.isHidden = true
            application.open(url!, options: [:], completionHandler: nil)
        }
    }
}
