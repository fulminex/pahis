//
//  Places.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation
import GoogleMaps

// https://api.myjson.com/bins/ewal0

struct Place: Decodable {
    let id: Int
    let nombre: String
    let imageUrlRaw: String
    let coord: Coord?
    
    static let apiURLRaw: String = "https://api.myjson.com/bins/ewal0"
    
    static var apiURL: URL! {
        return URL(string: apiURLRaw)!
    }
    
    var imageUrl: URL {
        return URL(string: imageUrlRaw)!
    }
    
    var location:CLLocation? {
        guard let latitud = coord?.latitud, let lat = Double(latitud) else {
            return nil
        }
        guard let longitud = coord?.longitud, let long = Double(longitud) else {
            return nil
        }
        return CLLocation(latitude: lat, longitude: long)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case imageUrlRaw = "imageUrl"
        case coord = "coordenadas"
    }
}

struct Coord: Decodable {
    let latitud: String?
    let longitud: String?
}
