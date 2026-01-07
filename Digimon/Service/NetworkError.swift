//
//  NetworkError.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case badURL
    case decodingError
    case unauthorized
    case serverError(code: Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .decodingError:
            return "Failed to decode the response"
        case .unauthorized:
            return "You are not authorized"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
