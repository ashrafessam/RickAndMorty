//
//  CharactersRepositoryImpl.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

final class CharactersRepositoryImpl: CharactersRepository {

    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchCharacters(from url: URL) async throws -> CharactersPage {
        try await apiClient.request(
            from: url,
            as: CharactersPage.self
        )
    }
}
