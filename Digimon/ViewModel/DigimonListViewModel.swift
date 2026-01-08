//
//  DigimonViewModel.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import Foundation
import Combine

enum DigimonListViewState {
    case loading
    case loaded([DigimonModel])
    case error(NetworkError)
}

struct FilterOptions {
    var levels: Set<String> = []
    var types: Set<String> = []
    var attributes: Set<String> = []
    var fields: Set<String> = []
}

@MainActor
class DigimonListViewModel: ObservableObject {
    
    @Published var searchText: String = "" {
        didSet {
            applyFiltersAndSearch()
        }
    }
    @Published private(set) var state: DigimonListViewState = .loading
    @Published var activeFilters = FilterOptions()
    
    var hasActiveFilters: Bool {
        !activeFilters.levels.isEmpty || !activeFilters.types.isEmpty ||
        !activeFilters.attributes.isEmpty || !activeFilters.fields.isEmpty
    }
    
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
            state = .loading
        }
        
        isLoading = true

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
            state = .error(error)
        } catch {
            state = .error(.unknown)
        }

        isLoading = false
    }
    
    private func loadNextBatchDetails() async {
        guard !isLoadingDetails, !pendingDigimons.isEmpty else { return }
        
        isLoadingDetails = true
        
        let batchSize = min(8, pendingDigimons.count)
        let batch = Array(pendingDigimons.prefix(batchSize))
        pendingDigimons.removeFirst(batchSize)
        
        var loadedDetails: [(DigimonModel, DigimonDetail?)] = []
        
        await withTaskGroup(of: (Int, DigimonDetail?).self) { group in
            for item in batch {
                if let cached = detailCache[item.id] {
                    loadedDetails.append((item, cached))
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
            
            var detailsMap: [Int: DigimonDetail] = [:]
            for await (id, detail) in group {
                if let detail = detail {
                    detailsMap[id] = detail
                    detailCache[id] = detail
                }
            }
            
            for item in batch {
                if let detail = detailsMap[item.id] {
                    loadedDetails.append((item, detail))
                } else if let cached = detailCache[item.id] {
                    loadedDetails.append((item, cached))
                }
            }
        }
        
        for (item, detail) in loadedDetails {
            if let detail = detail {
                var itemWithDetail = item
                itemWithDetail.cachedDetail = detail
                allDigimons.append(itemWithDetail)
            }
        }
        
        isLoadingDetails = false
        
        applyFiltersAndSearch()
    }
    
    func getAllDigimons() -> [DigimonModel] {
        return allDigimons
    }
    
    func applyFilters(levels: Set<String>, types: Set<String>, attributes: Set<String>, fields: Set<String>) {
        activeFilters = FilterOptions(
            levels: levels,
            types: types,
            attributes: attributes,
            fields: fields
        )
        applyFiltersAndSearch()
    }
    
    func refresh() async {
        allDigimons.removeAll()
        pendingDigimons.removeAll()
        detailCache.removeAll()
        currentPage = 0
        hasMoreData = true
        totalPages = 0
        activeFilters = FilterOptions()
        await loadNextPage()
    }
    
    private func applyFiltersAndSearch() {
        var result = allDigimons.filter { $0.cachedDetail != nil }
        
        if hasActiveFilters {
            result = result.filter { digimon in
                guard let detail = digimon.cachedDetail else { return false }
                
                var matches = true
                
                if !activeFilters.levels.isEmpty {
                    let digimonLevels = detail.levels?.map { $0.level } ?? []
                    matches = matches && !Set(digimonLevels).isDisjoint(with: activeFilters.levels)
                }
                
                if !activeFilters.types.isEmpty {
                    let digimonTypes = detail.types?.map { $0.type } ?? []
                    matches = matches && !Set(digimonTypes).isDisjoint(with: activeFilters.types)
                }
                
                if !activeFilters.attributes.isEmpty {
                    let digimonAttributes = detail.attributes?.map { $0.attribute } ?? []
                    matches = matches && !Set(digimonAttributes).isDisjoint(with: activeFilters.attributes)
                }
                
                if !activeFilters.fields.isEmpty {
                    let digimonFields = detail.fields?.map { $0.field } ?? []
                    matches = matches && !Set(digimonFields).isDisjoint(with: activeFilters.fields)
                }
                
                return matches
            }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { digimon in
                let nameMatch = digimon.name.lowercased().contains(query)
                let levelMatch = digimon.displayLevel.lowercased().contains(query)
                let typeMatch = digimon.displayType.lowercased().contains(query)
                let attributeMatch = digimon.displayAttribute.lowercased().contains(query)
                let fieldMatch = digimon.displayFields.lowercased().contains(query)
                return nameMatch || levelMatch || typeMatch || attributeMatch || fieldMatch
            }
        }

        state = .loaded(result)
    }
}
