//
//  Defines.swift
//  KeyTalk
//
//  Created by Paurush on 5/17/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit

let screenHeight = UIScreen.main.bounds.height
let TABLE_LABEL_SIZE: CGFloat = 20.0
var keyBoardHeight: CGFloat = 0.0
var keytalkCookie = ""
var username = ""
var password = ""
var serviceName = ""
var hwsigRequired = false

let CERTIFICATE_MSG = "The control is going to be transferred to SAFARI. Please click on OK to install the certificate. \n To enter the password, Please long press on the password field and select Paste."
let SERVER_FAIL_MSG = "Error occurred in connection."
let EMAIL_REPORT_HTML = "This is an e-mail to the KeyTalk support desk.<br />Please replace this text with a description of the problem you are experiencing, and what you were doing when the problem occurred.<br /><br />The attached log file is required to let us help you as efficient as possible. It does not contain any personal information.";
// Email subject
let EMAIL_REPORT_SUBJECT = "KeyTalk iOS client - Error report";
