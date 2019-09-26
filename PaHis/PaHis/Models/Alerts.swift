//
//  Alerts.swift
//  PaHis
//
//  Created by Leonardo Luna on 9/26/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

struct Alert: Decodable {
    let address, dateCreated, dateModified, welcomeDescription: String?
    let id: Int
    let images: [Image]
    let inmueble: Int?
    let latitude, longitude: Double?
    var name, state: String?
    let user: Int?

    enum CodingKeys: String, CodingKey {
        case address
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case welcomeDescription = "description"
        case id, images, inmueble, latitude, longitude, name, state, user
    }
}

struct Image: Decodable {
    let url: String
}
