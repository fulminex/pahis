//
//  CineTauroViewController.swift
//  PaHis
//
//  Created by Leo on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class CineTauroViewController: UIViewController {
    
    @IBOutlet weak var textUITextfield: UITextView!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autorLabel.textColor = UIColor(rgb: 0xF5391C)
        yearLabel.textColor = UIColor(rgb: 0xF5391C)
//        textUITextfield.isScrollEnabled = true
//        resize(textView: textUITextfield)
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
