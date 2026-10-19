//
//  MockCharactersRepository.swift
//  RickAndMortyTests
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation
@testable import RickAndMorty

final class MockCharactersRepository: CharactersRepository {

    var result: Result<CharactersPage, Error>?

    func fetchCharacters(
        from url: URL
    ) async throws -> CharactersPage {
        guard let result else {
            throw APIError.emptyResponse
        }

        return try result.get()
    }
}
