//
//  ImportCell.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import Foundation
import UIKit

class ImportCell: UITableViewCell {
    
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblSubHeading: UILabel!
    
    @IBOutlet var btnShowMeHow: UIButton!
    @IBOutlet var btnImport: UIButton!
    @IBOutlet var btnlangchange: UIButton!
    
    @IBOutlet var textFieldUrl: UITextField!
    @IBOutlet var viewShowMeHow: UIView!
    
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}

class ReportAndRemoveCell: UITableViewCell {
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var btnReportAndRemove: UIButton!
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}
class AppLockCell :UITableViewCell {
    @IBOutlet var appLockSwitch : UISwitch!
    @IBOutlet var lAppunlock: UILabel!
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}
//class ClientIdentifierCell: UITableViewCell {
//    @IBOutlet var lblUDID: UILabel!
//    @IBOutlet var lblClientIdentifier: UILabel!
//    @IBOutlet weak var lvlClientIdentifierDetail: UILabel!
//
//    //MARK:- LifeCycleMethods
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    deinit {
//    }
//}

class HelpCell: UITableViewCell {
   
    @IBOutlet var lblStepone: UILabel!
    @IBOutlet var lblsteponedetails: UILabel!
    @IBOutlet var lblSteptwo: UILabel!
    @IBOutlet var lblsteptwodetails: UILabel!
    @IBOutlet var lblStepthree: UILabel!
    @IBOutlet var lblstepthreedetails: UILabel!
    @IBOutlet var lblStepfour: UILabel!
    @IBOutlet var lblstepfourdetails: UILabel!
    @IBOutlet var imgstepone: UIImageView!
    @IBOutlet var imgsteptwo: UIImageView!
    @IBOutlet var imgstepthree: UIImageView!
    @IBOutlet var imgstepfour: UIImageView!
    
    
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}
