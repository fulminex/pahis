//
//  AlertCollectionViewCell.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/6/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class AlertCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var row: Int!
    var deletegate: DeletePhotoDelegate!
    
    static let identifier =  "AlertCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var photo: UIImage? {
        didSet {
            photoImageView.image = photo
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deletegate.deletePhotoAt(row: row)
    }
}
