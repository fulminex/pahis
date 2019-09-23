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
    
    var place: DisplayedBuildingPahis! {
        didSet {
            descriptionLabel.text = place.name + "\nCategoría: \(place.category)" + "\n\(place.distance == nil ? "-" : "A \(place.distance ?? 0) kilómetros")"
                
                //place.name + "\nLatitud: \(place.latitud ?? "-")" + "\nLongitud: \(place.longitud ?? "-")" + "\nDistancia: \(place.distance == nil ? "-" : "\(place.distance ?? 0) kilometros")"
            
            if let urlRaw = place.imageURL, let url = URL(string: urlRaw) {
                photoImage.kf.indicatorType = .activity
                photoImage.kf.setImage(with: url)
            } else {
                photoImage.image = UIImage(named: "NoImageIcon")
            }
        }
    }
}
