//
//  DetailBuildingCollectionViewCell.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/5/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher

class DetailBuildingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    static let identifier = "DetailBuildingCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var urlImageRaw: String? {
        didSet {
            guard let url = URL(string: urlImageRaw!) else {
                photoImageView.image = UIImage(named: "NoImageIcon")
                return
            }
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: url)
        }
    }
}
