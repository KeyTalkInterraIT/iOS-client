//
//  HelpVC.swift
//  KeyTalk
//  Created by Paurush on 6/18/18.

import UIKit

class HelpVC: UIViewController, UITableViewDataSource {
    @IBOutlet var helptableView: UITableView!
    //MARK:- LifeCycle Methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Rendering the view, for iphoneX.
        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
        
    }

    //MARK:- IB Actions
    
    /**
     Action method to dismiss the view.
     */
    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- TableView Delegates and DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //sets the cell with the identifier 'helpCell'
        var cell = tableView.dequeueReusableCell(withIdentifier: "helpCell") as? HelpCell
       
        cell = stepview() as? HelpCell
        if let h_cell = cell {
            h_cell.selectionStyle = .none
            return h_cell
        } else {
            return stepview()
        }
    }

    // MARK: Private Methods
    /**
     This funtions creates a tableview cell of type helpCell.
     - Returns: a UITableViewCell of type HelpCell.
     */
    private func stepview() -> UITableViewCell {
        let cell = helptableView.dequeueReusableCell(withIdentifier: "helpCell") as? HelpCell
        if let s_cell = cell {
            s_cell.lblStepone.text = "step_one".localized(KTLocalLang)
            s_cell.lblsteponedetails.text = "step_one_instruction_string".localized(KTLocalLang)
            s_cell.lblSteptwo.text = "step_two".localized(KTLocalLang)
            s_cell.lblsteptwodetails.text = "step_two_instruction_string".localized(KTLocalLang)
            s_cell.lblStepthree.text = "step_three".localized(KTLocalLang)
            s_cell.lblstepthreedetails.text = "step_three_instruction_string".localized(KTLocalLang)
            s_cell.lblStepfour.text = "step_four".localized(KTLocalLang)
            s_cell.lblstepfourdetails.text = "step_four_instruction_string".localized(KTLocalLang)
            return s_cell
        } else {
            return cell!
        }
    }
    
    
}
