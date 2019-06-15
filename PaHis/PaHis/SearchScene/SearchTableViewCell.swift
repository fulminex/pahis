//
//  SearchTableViewCell.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher

class PlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "PlaceTableViewCell"
    
    var place: DisplayedPlace! {
        didSet {
            descriptionLabel.text = place.name + "\nLatitud: \(place.latitud ?? "-")" + "\nLongitud: \(place.longitud ?? "-")" + "\nDistancia: \(place.distance == nil ? "-" : "\(place.distance ?? 0) kilometros")"
            photoImage.kf.indicatorType = .activity
            photoImage.kf.setImage(with: place.imageUrl)
        }
    }
}
