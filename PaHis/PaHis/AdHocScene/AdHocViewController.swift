//
//  AdHocViewController.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class AdHocViewController : UIViewController {
    
    @IBOutlet weak var registrosButton: UIButton!
    @IBOutlet weak var alertasButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registrosButton.tintColor = UIColor(rgb: 0xF5391C)
        alertasButton.tintColor = UIColor(rgb: 0xF5391C)
        self.title = "Alertas"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
}
