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

class ClientIdentifierCell: UITableViewCell {
    @IBOutlet var lblUDID: UILabel!
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}

class HelpCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    //MARK:- LifeCycleMethods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
    }
}
