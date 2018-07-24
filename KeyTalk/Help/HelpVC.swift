//
//  HelpVC.swift
//  KeyTalk
//
//  Created by Paurush on 6/18/18.
//  Copyright © 2018 Paurush. All rights reserved.
//

import UIKit

class HelpVC: UIViewController, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIScreen.main.bounds.height == 812 {
            Utilities.changeViewAccToXDevices(view: self.view)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpCell")
        return cell!
    }

}
