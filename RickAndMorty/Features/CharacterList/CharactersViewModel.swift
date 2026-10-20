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
    private(set) var nextPageURL: URL?
    private(set) var isLoadingNextPage = false

    private let repository: any CharactersRepository

    private let charactersURL = APIConstants.baseURL
        .appending(path: "character")

    init(repository: any CharactersRepository) {
        self.repository = repository
    }

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
        } catch {
            print("Fetch characters failed:", error)
            errorMessage = "Failed to load characters. Please try again."
        }
    }
    func loadNextPage() async {
        guard !isLoading,!isLoadingNextPage,let nextPageURL else { return }
        
        paginationErrorMessage = nil
        isLoadingNextPage = true
        
        defer {
            isLoadingNextPage = false
        }

        do {
            let page = try await repository.fetchCharacters(from: nextPageURL)

            let existingIDs = Set(characters.map(\.id))
            let newCharacters = page.results.filter {
                !existingIDs.contains($0.id)
            }

            characters.append(contentsOf: newCharacters)
            self.nextPageURL = page.info.next.flatMap { URL(string: $0) }
        } catch {
            print("Pagination failed:", error)
            paginationErrorMessage = "Failed to load more characters. Please try again."
        }
    }
}
