//
//  Ubigeo.swift
//  PaHis
//
//  Created by Carolina Esquivel on 9/22/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

// MARK: - Ubigeo
struct Ubigeo: Decodable {
    let codUbigeo: String?
    let nombre: String?

    enum CodingKeys: String, CodingKey {
        case codUbigeo = "cod_ubigeo"
        case nombre
    }
}
