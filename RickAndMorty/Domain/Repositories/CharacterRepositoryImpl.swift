//
//  CharactersRepositoryImpl.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

@MainActor
final class CharactersRepositoryImpl: CharactersRepository {
    private let apiClient: any APIClientProtocol
    private let localStore: CharactersLocalStore

    init(
        apiClient: any APIClientProtocol,
        localStore: CharactersLocalStore
    ) {
        self.apiClient = apiClient
        self.localStore = localStore
    }

    func fetchCharacters(from url: URL) async throws -> CharactersPage {
        let page = try await apiClient.request(
            from: url,
            as: CharactersPage.self
        )

        try localStore.save(page.results)

        return page
    }


    func fetchCachedCharacters() throws -> [Character] {
        try localStore.fetchAll()
    }
    
    
}
