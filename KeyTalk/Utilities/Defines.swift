//
//  Defines.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.

import Foundation
import UIKit

///These are the global variables defined and can be accessed anywhere with the app.

//the height of the screen.
let screenHeight = UIScreen.main.bounds.height

//the size of the label in drop down table/menu.
let TABLE_LABEL_SIZE: CGFloat = 20.0

//sets the height of the keyBoard.
var keyBoardHeight: CGFloat = 0.0

//cookie retrieved after hello hit is stored in this variable, also it needs to be attached in the header of every request.
var keytalkCookie = ""

//username entered by the user.
var username = ""

//password entered by the user.
var password = ""

//variable to save locale code throughout the application
var KTLocalLang = ""

//service name entered or selected by the user.
var serviceName = ""

//indicates wheather the hardware signature is required for the authentication or not.
var hwsigRequired = false

//variable for challenge response
var challengeResponseArr = [[String:Any]]()
var challengeName = ""

//this message is shown to the user, when the control is moving to safari, in order to download the certificate.
let CERTIFICATE_MSG = "Certificate_msg_string".localized(KTLocalLang)

//generic error message.
let SERVER_FAIL_MSG = "Server_fail_msg_string".localized(KTLocalLang)

//This is the mail body, which is set in the mail composer , when the user reports about an issue.
let EMAIL_REPORT_HTML = "Email_report_html_string".localized(KTLocalLang)

// Report email subject
let EMAIL_REPORT_SUBJECT = "Email_report_subject_string".localized(KTLocalLang);

