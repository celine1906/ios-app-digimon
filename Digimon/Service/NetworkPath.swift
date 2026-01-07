//
//  NetworkPath.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation

enum NetworkPath {
    case getDigimons(pageSize: Int, page: Int)
    case getDigimonDetail(urlString: String)
    
    var url: URL? {
        switch self {
        case .getDigimons(let pageSize, let page):
            return URL(string:
                "https://digi-api.com/api/v1/digimon?pageSize=\(pageSize)&page=\(page)"
            )
        case .getDigimonDetail(let urlString):
            return URL(string: urlString)
        }
    }
}
