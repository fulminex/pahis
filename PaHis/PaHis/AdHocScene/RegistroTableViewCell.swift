//
//  RegistroTableViewCell.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher

class RegistroTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "RegistroTableViewCell"
    
    var registro: Registro! {
        didSet {
            descriptionLabel.text = registro.descripcion + "\nCategoría: \(registro.categoria)" + "\nDistrito: \(registro.distrito)" + "\nEstado: \(registro.estado)" + "\nObservaciones: \(registro.observaciones)"
            
            //place.name + "\nLatitud: \(place.latitud ?? "-")" + "\nLongitud: \(place.longitud ?? "-")" + "\nDistancia: \(place.distance == nil ? "-" : "\(place.distance ?? 0) kilometros")"
            
            if let url = URL(string: registro.photoRaw) {
                photoImage.kf.indicatorType = .activity
                photoImage.kf.setImage(with: url)
            } else {
                photoImage.image = UIImage(named: "NoImageIcon")
            }
        }
    }
}
