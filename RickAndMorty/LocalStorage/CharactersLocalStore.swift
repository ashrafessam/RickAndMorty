//
//  CharactersLocalStore.swift
//  RickAndMorty
//
//  Created by Ashraf on 20/10/2026.
//

import Foundation
import SwiftData

@MainActor
final class CharactersLocalStore {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ characters: [Character]) throws {
        let descriptor = FetchDescriptor<CachedCharacter>()
        let existingCharacters = try modelContext.fetch(descriptor)
        var charactersByID = Dictionary(
            uniqueKeysWithValues: existingCharacters.map { ($0.id, $0) }
        )

        for character in characters {
            if let cachedCharacter = charactersByID[character.id] {
                cachedCharacter.name = character.name
                cachedCharacter.status = character.status.rawValue
                cachedCharacter.species = character.species
                cachedCharacter.gender = character.gender
                cachedCharacter.originName = character.origin.name
                cachedCharacter.locationName = character.location.name
                cachedCharacter.imageURL = character.image?.absoluteString
            } else {
                let cachedCharacter = CachedCharacter(character: character)
                modelContext.insert(cachedCharacter)
                charactersByID[character.id] = cachedCharacter
            }
        }

        try modelContext.save()
    }

    func fetchAll() throws -> [Character] {
        let descriptor = FetchDescriptor<CachedCharacter>(
            sortBy: [SortDescriptor(\.id)]
        )

        return try modelContext.fetch(descriptor).map(\.asCharacter)
    }
}
