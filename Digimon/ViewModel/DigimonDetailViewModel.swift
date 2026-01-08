//
//  DigimonDetailViewModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 07/01/26.
//

import Foundation
import Combine

enum DetailViewState {
    case loading
    case loaded(DigimonDetail)
    case error(NetworkError)
}

final class DigimonDetailViewModel: ObservableObject {
    @Published private(set) var state: DetailViewState = .loading
    private let network = NetworkService()
    private let href: String
    private let cachedDetail: DigimonDetail?

    init(href: String, cachedDetail: DigimonDetail?) {
        self.href = href
        self.cachedDetail = cachedDetail
    }

    func load() async {
        if let cachedDetail {
            state = .loaded(cachedDetail)
            return
        }

        do {
            let detail: DigimonDetail = try await network.request(
                .getDigimonDetail(urlString: href)
            )
            state = .loaded(detail)
        } catch let error as NetworkError {
            state = .error(error)
        } catch {
            state = .error(.unknown)
        }
    }
}
