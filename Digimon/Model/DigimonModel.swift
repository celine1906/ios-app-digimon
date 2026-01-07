//
//  DigimonModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation

struct DigimonListResponse: Codable {
    let content: [DigimonModel]
    let pageable: PageableInfo?
}

struct PageableInfo: Codable {
    let currentPage: Int
    let elementsOnPage: Int
    let totalElements: Int
    let totalPages: Int
    let previousPage: String
    let nextPage: String
}

struct DigimonModel: Codable, Identifiable {
    let id: Int
    let name: String
    let href: String
    let image: String
    var cachedDetail: DigimonDetail?
    
    var displayLevel: String {
        cachedDetail?.levels?.first?.level ?? ""
    }
    
    var displayType: String {
        cachedDetail?.types?.first?.type ?? ""
    }
    
    var displayAttribute: String {
        cachedDetail?.attributes?.first?.attribute ?? ""
    }
    
    var displayFields: String {
        guard let fields = cachedDetail?.fields else { return "" }
        return fields.map { $0.field }.joined(separator: "  ")
    }
}

