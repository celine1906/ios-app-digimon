//
//  FavoriteManager.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 08/01/26.
//

import Foundation
import Combine

final class FavoriteManager {
    static let shared = FavoriteManager()
    
    private let favoritesKey = "favoriteDigimons"
    private let favoritesSubject = PassthroughSubject<Void, Never>()
    
    var favoritesDidChange: AnyPublisher<Void, Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    private init() {}
    
    func addFavorite(id: Int, href: String) {
        var favorites = getFavorites()
        let favorite = FavoriteDigimon(id: id, href: href)
        
        if !favorites.contains(where: { $0.id == id }) {
            favorites.append(favorite)
            saveFavorites(favorites)
            favoritesSubject.send()
        }
    }
    
    func removeFavorite(id: Int) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == id }
        saveFavorites(favorites)
        favoritesSubject.send()
    }
  
    func isFavorite(id: Int) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == id }
    }
    
    func toggleFavorite(id: Int, href: String) -> Bool {
        if isFavorite(id: id) {
            removeFavorite(id: id)
            return false
        } else {
            addFavorite(id: id, href: href)
            return true
        }
    }
    
    func getFavorites() -> [FavoriteDigimon] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([FavoriteDigimon].self, from: data) else {
            return []
        }
        return favorites
    }
    
    private func saveFavorites(_ favorites: [FavoriteDigimon]) {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
