//
//  DetailBuildingTableViewCell.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/5/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class DetailBuildingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    static let identifier = "DetailBuildingTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var documentName: String? {
        didSet {
            let nameOnly = documentName?.split(separator: "/").last
            documentNameLabel.text = String(nameOnly ?? "No File Found")
        }
    }
}
