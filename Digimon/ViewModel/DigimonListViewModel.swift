//
//  DigimonViewModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation
import SwiftUI
import Combine

enum DigimonListViewState {
    case loading
    case loaded([DigimonModel])
    case error(NetworkError)
}

class DigimonListViewModel: ObservableObject {
    
    @Published var searchText: String = "" {
        didSet {
            applySearch()
        }
    }
    @Published private(set) var state: DigimonListViewState = .loading
    
    private var allDigimons: [DigimonModel] = []
    private var pendingDigimons: [DigimonModel] = []
    private var currentPage = 0
    private let pageSize = 8
    private var isLoading = false
    private var isLoadingDetails = false
    private var hasMoreData = true
    private var totalPages = 0
    private let network = NetworkService()
    
    private var detailCache: [Int: DigimonDetail] = [:]
    
    func fetchInitial() async {
        guard allDigimons.isEmpty else { return }
        currentPage = 0
        hasMoreData = true
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading, hasMoreData else { return }
        
        if !pendingDigimons.isEmpty {
            await loadNextBatchDetails()
            return
        }
        
        if totalPages > 0 && currentPage >= totalPages {
            hasMoreData = false
            return
        }
        
        if allDigimons.isEmpty {
            updateState(.loading)
        }
        
        isLoading = true

        Task {
            do {
                let response: DigimonListResponse = try await network.request(
                    .getDigimons(pageSize: pageSize, page: currentPage)
                )

                if let pageable = response.pageable {
                    totalPages = pageable.totalPages
                }
                
                if response.content.count < pageSize || currentPage >= totalPages - 1 {
                    hasMoreData = false
                }
                
                currentPage += 1
                
                pendingDigimons.append(contentsOf: response.content)
                
                await loadNextBatchDetails()
                
            } catch let error as NetworkError {
                updateState(.error(error))
            } catch {
                updateState(.error(.unknown))
            }

            isLoading = false
        }
    }
    
    private func loadNextBatchDetails() async {
        guard !isLoadingDetails, !pendingDigimons.isEmpty else { return }
        
        isLoadingDetails = true
        
        // Ambil 8 items pertama dari pending
        let batchSize = min(8, pendingDigimons.count)
        let batch = Array(pendingDigimons.prefix(batchSize))
        pendingDigimons.removeFirst(batchSize)
        
        // Load details untuk batch ini secara parallel
        await withTaskGroup(of: (Int, DigimonDetail?).self) { group in
            for item in batch {
                if let cached = detailCache[item.id] {
                    // Sudah di-cache, langsung pakai
                    var itemWithDetail = item
                    itemWithDetail.cachedDetail = cached
                    allDigimons.append(itemWithDetail)
                    continue
                }
                
                group.addTask {
                    do {
                        let detail: DigimonDetail = try await self.network.request(
                            .getDigimonDetail(urlString: item.href)
                        )
                        return (item.id, detail)
                    } catch {
                        print("Failed to load detail for \(item.name): \(error)")
                        return (item.id, nil)
                    }
                }
            }
            
            // Collect results
            for await (id, detail) in group {
                guard let detail = detail else { continue }
                detailCache[id] = detail
                
                if let item = batch.first(where: { $0.id == id }) {
                    var itemWithDetail = item
                    itemWithDetail.cachedDetail = detail
                    allDigimons.append(itemWithDetail)
                }
            }
        }
        
        isLoadingDetails = false
        
        applySearch()
    }
    
    func refresh() async {
        allDigimons.removeAll()
        pendingDigimons.removeAll()
        detailCache.removeAll()
        currentPage = 0
        hasMoreData = true
        totalPages = 0
        await loadNextPage()
    }
}

private extension DigimonListViewModel {
    func updateState(_ state: DigimonListViewState) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
    
    func applySearch() {
        let result: [DigimonModel]

        if searchText.isEmpty {
            result = allDigimons.filter { $0.cachedDetail != nil }
        } else {
            let query = searchText.lowercased()
            result = allDigimons.filter { digimon in
                guard digimon.cachedDetail != nil else { return false }
                
                let nameMatch = digimon.name.lowercased().contains(query)
                let levelMatch = digimon.displayLevel.lowercased().contains(query)
                let typeMatch = digimon.displayType.lowercased().contains(query)
                let attributeMatch = digimon.displayAttribute.lowercased().contains(query)
                let fieldMatch = digimon.displayFields.lowercased().contains(query)
                return nameMatch || levelMatch || typeMatch || attributeMatch || fieldMatch
            }
        }

        updateState(.loaded(result))
    }
}
