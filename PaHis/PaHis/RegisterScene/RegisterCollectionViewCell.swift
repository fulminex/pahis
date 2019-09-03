//
//  RegisterCollectionViewCell.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/3/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

protocol DeletePhotoDelegate {
    func deletePhotoAt(row: Int)
}

class RegisterCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RegisterCollectionViewCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: DeletePhotoDelegate!
    var row: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.setImage(UIImage(named: "CancelIcon")?.tinted(with: UIColor(rgb: 0xF5391C)), for: .normal)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate.deletePhotoAt(row: row)
    }
}
