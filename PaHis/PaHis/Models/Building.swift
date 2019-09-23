//
//  Building.swift
//  PaHis
//
//  Created by ulima on 6/15/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

// MARK: - Building
struct PageBuilding: Decodable {
    let hasNext, hasPrev: Bool?
    let items: [BuildingPahis]?

    enum CodingKeys: String, CodingKey {
        case hasNext = "has_next"
        case hasPrev = "has_prev"
        case items
    }
}

// MARK: - Building
struct BuildingPahis: Decodable {
    let address: String?
    let alerts: [Int]?
    let category: CategoryPahis?
    let codUbigeo, dateCreated, dateModified, departamento: String?
    let buildingDescription, distrito: String?
    let documents: [Document]?
    let editionRequests: [Int]?
    let id: Int32?
    let images: [Document]?
    let latitude, longitude: Double?
    let name: String?
    let pinnedImageURL: String?
    let provincia: String?
    
    enum CodingKeys: String, CodingKey {
        case address, alerts, category
        case codUbigeo = "cod_ubigeo"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case departamento
        case buildingDescription = "description"
        case distrito, documents
        case editionRequests = "edition_requests"
        case id, images, latitude, longitude, name
        case pinnedImageURL = "pinned_image_url"
        case provincia
    }
}

// MARK: - Category
struct CategoryPahis: Decodable, Comparable {
    let id: Int32?
    let name: String?
    
    static func == (lhs: CategoryPahis, rhs: CategoryPahis) -> Bool {
        return lhs.id! == rhs.id!
    }
    
    static func < (lhs: CategoryPahis, rhs: CategoryPahis) -> Bool {
        return lhs.name! < rhs.name!
    }
}

struct Document: Decodable {
    let url: String?
}
