//
//  MockCharactersRepository.swift
//  RickAndMortyTests
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation
@testable import RickAndMorty

@MainActor
final class MockCharactersRepository: CharactersRepository {
    var result: Result<CharactersPage, Error>?
    var results: [Result<CharactersPage, Error>] = []
    var cachedCharacters: [Character] = []

    private(set) var requestedURLs: [URL] = []

    func fetchCharacters(from url: URL) async throws -> CharactersPage {
        requestedURLs.append(url)

        if !results.isEmpty {
            let result = results.removeFirst()
            return try result.get()
        }

        guard let result else {
            throw APIError.emptyResponse
        }

        return try result.get()
    }

    func fetchCachedCharacters() throws -> [Character] {
        cachedCharacters
    }
}

