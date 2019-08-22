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
    let category: Category
    let documents: [String]
    let images: [String]
    let latitude: Double?
    let longitude: Double?
    let state: String
}

struct Building {
    let codBuild: String
    let desc: String
    let codDist: String
    let obser: String?
    let category: Category
    let x: String?
    let y: String?
    let zone: String?
    let latitudeRaw: String?
    let longitudeRaw: String?
    let address: String?
    let fachada: String?
    let tipNorma: String
    let numNorma: String
    let archiNorma: String?
    let distancia: Double?
}

struct Category {
    let name: String
    let id: Int
}
