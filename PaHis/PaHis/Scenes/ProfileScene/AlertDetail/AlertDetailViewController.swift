//
//  AlertDetailViewController.swift
//  PaHis
//
//  Created by Angel Herrera on 10/14/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher
import Agrume

class AlertDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var alert: Alert!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        if let image = alert.images.first {
            imageView.kf.setImage(with: URL(string: image.url))
        }
        nameLabel.text = "Nombre: " + (alert.name ?? "-")
        stateLabel.text = "Estado: " + (alert.state ?? "-")
        addressLabel.text = "Dirección: " + (alert.address ?? "-")
        descriptionLabel.text = "Descripción: " + (alert.description ?? "-")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        var urls = [URL]()
        self.alert.images.forEach({
            if let url = URL(string: $0.url) {
                urls.append(url)
            }
        })
        let agrume = Agrume(urls: urls, background: .blurred(.dark))
        agrume.show(from: self)
    }
}
