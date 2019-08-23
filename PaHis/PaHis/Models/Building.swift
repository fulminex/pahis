//
//  Building.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

struct BuildingPahis {
    let id: Int
    let name: String
    let address: String
    let description: String
    let category: CategoryPahis
    let documents: [String]
    let images: [String]
    let latitude: Double?
    let longitude: Double?
    let state: String
}

struct CategoryPahis {
    let name: String
    let id: Int
}
