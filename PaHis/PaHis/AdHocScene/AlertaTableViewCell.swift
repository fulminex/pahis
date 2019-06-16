//
//  AlertaTableViewCell.swift
//  PaHis
//
//  Created by ulima on 6/16/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import UIKit
import Kingfisher

class AlertaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    static let identifier = "AlertaTableViewCell"
    
    var alerta: Alerta! {
        didSet {
            descriptionLabel.text = "Código de inmueble: \(alerta.codInmueble)" + "\nDetalle: \(alerta.descripcion)" + "\nDirección: \(alerta.dirección)"
            
            //place.name + "\nLatitud: \(place.latitud ?? "-")" + "\nLongitud: \(place.longitud ?? "-")" + "\nDistancia: \(place.distance == nil ? "-" : "\(place.distance ?? 0) kilometros")"
            
            if let url = URL(string: alerta.photoRaw) {
                photoImage.kf.indicatorType = .activity
                photoImage.kf.setImage(with: url)
            } else {
                photoImage.image = UIImage(named: "NoImageIcon")
            }
        }
    }
}
