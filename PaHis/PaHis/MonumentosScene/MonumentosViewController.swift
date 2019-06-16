//
//  MonumentosViewController.swift
//  PaHis
//
//  Created by Leo on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class MonumentosViewController: UIViewController {


    @IBOutlet weak var estiloButton: UIButton!
    @IBOutlet weak var autorButton: UIButton!
    @IBOutlet weak var periodoLabel: UILabel!
    @IBOutlet weak var usoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estiloButton.tintColor = UIColor(rgb: 0xF5391C)
        autorButton.tintColor = UIColor(rgb: 0xF5391C)
        periodoLabel.textColor = UIColor(rgb: 0xF5391C)
        usoLabel.textColor = UIColor(rgb: 0xF5391C)
        
        self.title = "Monumentos"
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
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
