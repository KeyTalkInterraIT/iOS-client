//
//  ImportVC.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import UIKit
import MessageUI

class ImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    @IBOutlet var tblSettings: UITableView!
    @IBOutlet var viewAbout: UIView!
    @IBOutlet var lblVersion: UILabel!
    
    let importModel = ImportModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblVersion.text = "Version: " + Utilities.getVersionNumber()+"(\(Utilities.getBuildNumber()))"
        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Datasource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.row == 0 {
            cell = getImportCell()
        }
        else if indexPath.row == 1 || indexPath.row == 2 {
            cell = getReportCell(index: indexPath.row)
        }
        else {
            cell = getIdentifierCell()
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if indexPath.row == 0 {
            height = 300
        }
        else if indexPath.row == 3 {
            height = 200
        }
        else {
            height = 120
        }
        return height
    }
    
    // MARK: Private Methods
    private func getImportCell() -> UITableViewCell {
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "importCell") as! ImportCell
        cell.btnImport.tag = 0
        cell.btnImport.addTarget(self, action: #selector(cellAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    private func getReportCell(index: Int) -> UITableViewCell {
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "rrCell") as! ReportAndRemoveCell
        if index == 1 {
            cell.lblHeading.text = "Email Reports of any issues to your administrator."
            cell.btnReportAndRemove.setTitle("SEND REPORT", for: .normal)
        }
        else {
            cell.lblHeading.text = "Remove all previously imported providers and services."
            cell.btnReportAndRemove.setTitle("REMOVE CONFIGURATION", for: .normal)
        }
        cell.btnReportAndRemove.tag = index
        cell.btnReportAndRemove.addTarget(self, action: #selector(cellAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    private func getIdentifierCell() -> UITableViewCell {
        let cell = tblSettings.dequeueReusableCell(withIdentifier: "identifierCell") as! ClientIdentifierCell
        let UDID = KMOpenUDID.value()!
//        if let str = KMOpenUDID.value() {
//            for i in 1...str.count {
//                if i % 3 == 0 {
//                    UDID.insert("-", at: String.Index.init(encodedOffset: i))
//                }
//            }
//        }
        
        cell.lblUDID.text = UDID
        return cell
    }
    
    @objc func cellAction(sender: UIButton) {
        if sender.tag == 0 {
            let indexPath = IndexPath.init(row: 0, section: 0)
            let cell = tblSettings.cellForRow(at: indexPath) as! ImportCell
            if let text = cell.textFieldUrl.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if text.count > 0 {
                    let url = URL.init(string: text)
                    if let _ = url {
                        downloadRccdThroughUrl(aDownloadUrl: text)
                    }
                    else {
                        cell.textFieldUrl.text = ""
                        Utilities.showAlert(message: "Please enter valid url.", owner: self)
                    }
                }
                else {
                    Utilities.showAlert(message: "Please enter the url.", owner: self)
                }
            }
        }
        else if sender.tag == 1 {
            openMailComposer()
        }
        else if sender.tag == 2 {
            Utilities.showAlertWithCancel(message: "Are you sure you want to delete all data?", owner: self, completionHandler: { (success) in
                if success {
                    Utilities.deleteAllDataFromDB()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let vc = appDelegate.window?.rootViewController as? ViewController
                    if let tempVC = vc {
                        if  tempVC.isKind(of: ViewController.self) {
                            tempVC.resetAll(aServicesArray: true)
                        }
                    }
                    
                }
            })
        }
    }
    
    private func downloadRccdThroughUrl( aDownloadUrl: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let vc = appDelegate.window?.rootViewController as? ViewController
        if let tempVC = vc {
            if  tempVC.isKind(of: ViewController.self) {
                self.dismiss(animated: true, completion: nil)
                tempVC.downloadRccdThroughUrl(aDownloadUrl: aDownloadUrl)
            }
        }
    }
    
    private func openMailComposer() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["support@keytalk.com"])
        mailComposer.setSubject(EMAIL_REPORT_SUBJECT)
        let body = "<html><body>\(EMAIL_REPORT_HTML)</html></body>"
        mailComposer.setMessageBody(body, isHTML: true)
        let attachmentData = HWSIGCheck.systemInfo() + Log.queryLog()
        let data = attachmentData.data(using: .utf8)
        if let data = data {
            mailComposer.addAttachmentData(data, mimeType: "text/plain", fileName: "client.log")
        }
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Action Methods
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func infoClicked() {
        viewAbout.isHidden = false
    }
    
    @IBAction func okClicked() {
        viewAbout.isHidden = true
    }
    
    @IBAction func urlClicked() {
        let url = URL.init(string: "https://www.keytalk.com")
        let application = UIApplication.shared
        if application.canOpenURL(url!) {
            viewAbout.isHidden = true
            application.open(url!, options: [:], completionHandler: nil)
        }
    }
}
