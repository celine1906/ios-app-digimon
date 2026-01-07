//
//  NetworkService.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation

final class NetworkService {
    func request<T: Decodable>(_ path: NetworkPath) async throws -> T {
        guard let url: URL = path.url else {
            throw NetworkError.badURL
        }
        var request: URLRequest = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                print("RAW JSON:")
                print(String(data: data, encoding: .utf8) ?? "nil")
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        case 400...499:
            throw NetworkError.serverError(code: httpResponse.statusCode)
        case 500...599:
            throw NetworkError.serverError(code: httpResponse.statusCode)
        default:
            throw NetworkError.unknown
        }
    }
}
