//
//  DigimonDetailModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation

struct DigimonDetail: Codable {
    let id: Int
    let name: String
    let xAntibody: Bool?
    let images: [DigimonImage]?
    let levels: [DigimonLevel]?
    let types: [DigimonType]?
    let attributes: [DigimonAttribute]?
    let fields: [DigimonField]?
    let releaseDate: String?
    let descriptions: [DigimonDescription]?
}

struct DigimonImage: Codable {
    let href: String
    let transparent: Bool
}

struct DigimonLevel: Codable {
    let id: Int
    let level: String
}

struct DigimonType: Codable {
    let id: Int
    let type: String
}

struct DigimonAttribute: Codable {
    let id: Int
    let attribute: String
}

struct DigimonField: Codable {
    let id: Int
    let field: String
    let image: String?
}

struct DigimonDescription: Codable {
    let origin: String
    let language: String
    let description: String
}

