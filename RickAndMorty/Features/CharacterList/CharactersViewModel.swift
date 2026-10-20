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

    private(set) var characters: [Character] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var paginationErrorMessage: String?
    private(set) var refreshErrorMessage: String?
    private(set) var nextPageURL: URL?
    private(set) var isLoadingNextPage = false

    private let repository: any CharactersRepository

    private let charactersURL = APIConstants.baseURL
        .appending(path: "character")

    init(repository: any CharactersRepository) {
        self.repository = repository
    }
    
    var searchText = ""
    var selectedSort: SortOption = .default

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

    var selectedStatus: StatusFilter = .all

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

            characters = page.results
            nextPageURL = page.info.next.flatMap { URL(string: $0) }
            
            errorMessage = nil
            paginationErrorMessage = nil
            refreshErrorMessage = nil
        } catch {
            print("Fetch characters failed:", error)
            errorMessage = "Failed to load characters. Please try again."
        }
    }
    func retryInitialLoading() async {
        await fetchCharacters()
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
            print("Pagination failed:", error)
            paginationErrorMessage =
                "Failed to load more characters. Please try again."
        }
    }

    func refreshCharacters() async {
        guard !isLoading, !isLoadingNextPage else { return }

        refreshErrorMessage = nil
        do {
            print("Refresh Started")
            let page = try await repository.fetchCharacters(from: charactersURL)
            print("Refresh Completed")

            characters = page.results
            nextPageURL = page.info.next.flatMap { URL(string: $0) }
            paginationErrorMessage = nil
            refreshErrorMessage = nil
            errorMessage = nil
        } catch {
            print("Refresh failed:", error)
            refreshErrorMessage = "Failed to refresh characters. Please try again."
        }
    }
}
