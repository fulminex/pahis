//
//  ProfileTableViewController.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/25/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageVIew: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = User.currentUser else {
            let alert = UIAlertController(title: "Aviso", message: "Su sessión ha expirado", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let details = NSMutableAttributedString(string: "\(currentUser.name)", attributes:
            [
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ])
        details.append(NSAttributedString(string: "\n\(currentUser.type)", attributes:
            [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),
                NSAttributedString.Key.foregroundColor : UIColor.lightGray
            ]))
        nameLabel.attributedText = details
        photoImageVIew.layer.cornerRadius = self.photoImageVIew.frame.size.width / 2
        photoImageVIew.clipsToBounds = true
        photoImageVIew.contentMode = .scaleAspectFill
    }

}
