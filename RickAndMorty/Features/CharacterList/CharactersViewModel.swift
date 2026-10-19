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

    private let repository: any CharactersRepository

    private let baseURL = URL(
        string: "https://rickandmortyapi.com/api/character"
    )!

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
                from: baseURL
            )

            characters = page.results
        } catch {
            errorMessage = "Failed to load characters. Please try again."
        }
    }
}
