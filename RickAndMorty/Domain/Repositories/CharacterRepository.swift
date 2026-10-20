//
//  CharacterRepository.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

@MainActor
protocol CharactersRepository {
    func fetchCharacters(from url: URL) async throws -> CharactersPage
    func fetchCachedCharacters() throws -> [Character]
}
