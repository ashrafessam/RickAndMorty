//
//  CharactersViewModel.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CharactersViewModel {
    
    // MARK: - State
    private(set) var characters: [Character] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var paginationErrorMessage: String?
    private(set) var refreshErrorMessage: String?
    private(set) var nextPageURL: URL?
    private(set) var isLoadingNextPage = false
    
    var searchText = ""
    var selectedSort: SortOption = .default
    var selectedStatus: StatusFilter = .all
    
    // MARK: - Dependencies
    private let repository: any CharactersRepository
    
    private let charactersURL = APIConstants.baseURL
        .appending(path: "character")
    
    // MARK: - Initialization
    init(repository: any CharactersRepository) {
        self.repository = repository
    }
    
    // MARK: - Filter & Sort Types
    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "Unknown"
        
        var id: String { rawValue }
        
        var characterStatus: CharacterStatus? {
            switch self {
            case .all:
                return nil
            case .alive:
                return .alive
            case .dead:
                return .dead
            case .unknown:
                return .unknown
            }
        }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case `default` = "Default"
        case nameAscending = "Name A–Z"
        case nameDescending = "Name Z–A"
        
        var id: String { rawValue }
    }
    
    
    
    // MARK: - Computed Properties
    var filteredCharacters: [Character] {
        let filtered = characters.filter { character in
            let matchesSearch =
            searchText.isEmpty ||
            character.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus =
            selectedStatus.characterStatus == nil ||
            character.status == selectedStatus.characterStatus
            
            return matchesSearch && matchesStatus
        }
        
        switch selectedSort {
        case .default:
            return filtered
            
        case .nameAscending:
            return filtered.sorted {
                $0.name.localizedCompare($1.name) == .orderedAscending
            }
            
        case .nameDescending:
            return filtered.sorted {
                $0.name.localizedCompare($1.name) == .orderedDescending
            }
        }
    }
    
    // MARK: - Public Methods
    func fetchCharacters() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let page = try await repository.fetchCharacters(
                from: charactersURL
            )
            
            updateCharacters(with: page)
            
            errorMessage = nil
            paginationErrorMessage = nil
            refreshErrorMessage = nil
        } catch {
            errorMessage = "Failed to load characters. Please try again."
        }
    }
    
    func loadNextPage() async {
        guard !isLoading, !isLoadingNextPage, nextPageURL != nil else {
            return
        }
        
        let initialFilteredCount = filteredCharacters.count
        
        paginationErrorMessage = nil
        isLoadingNextPage = true
        
        defer {
            isLoadingNextPage = false
        }
        
        do {
            while let url = nextPageURL,
                  filteredCharacters.count <= initialFilteredCount {
                
                let page = try await repository.fetchCharacters(from: url)
                
                var existingIDs = Set(characters.map(\.id))
                
                let newCharacters = page.results.filter { character in
                    existingIDs.insert(character.id).inserted
                }
                
                characters.append(contentsOf: newCharacters)
                nextPageURL = page.info.next.flatMap { URL(string: $0) }
            }
        } catch {
            paginationErrorMessage =
            "Failed to load more characters. Please try again."
        }
    }
    func refreshCharacters() async {
        guard !isLoading, !isLoadingNextPage else { return }
        
        refreshErrorMessage = nil
        do {
            
            let page = try await repository.fetchCharacters(from: charactersURL)
            
            updateCharacters(with: page)
            
            paginationErrorMessage = nil
            refreshErrorMessage = nil
            errorMessage = nil
        } catch {
            refreshErrorMessage = "Failed to refresh characters. Please try again."
        }
    }
    // MARK: - Private Methods
    private func updateCharacters(with page: CharactersPage) {
        characters = page.results
        nextPageURL = page.info.next.flatMap { URL(string: $0) }
    }
}
