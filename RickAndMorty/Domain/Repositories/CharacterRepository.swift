//
//  CharacterRepository.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

protocol CharactersRepository {
    func fetchCharacters(from url: URL) async throws -> CharactersPage
}
