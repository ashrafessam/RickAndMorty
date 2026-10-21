//
//  CachedCharacter.swift
//  RickAndMorty
//
//  Created by Ashraf on 20/10/2026.
//

import Foundation
import SwiftData

@Model
final class CachedCharacter {
    @Attribute(.unique) var id: Int
    var name: String
    var status: String
    var species: String
    var gender: String
    var originName: String
    var locationName: String
    var imageURL: String?

    init(
        id: Int,
        name: String,
        status: String,
        species: String,
        gender: String,
        originName: String,
        locationName: String,
        imageURL: String?
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.gender = gender
        self.originName = originName
        self.locationName = locationName
        self.imageURL = imageURL
    }
    
    
    var asCharacter: Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(rawValue: status) ?? .unknown,
            species: species,
            gender: gender,
            origin: .init(name: originName),
            location: .init(name: locationName),
            image: imageURL.flatMap(URL.init(string:)),
            episode: []
        )
    }
    
    
    convenience init(character: Character) {
        self.init(
            id: character.id,
            name: character.name,
            status: character.status.rawValue,
            species: character.species,
            gender: character.gender,
            originName: character.origin.name,
            locationName: character.location.name,
            imageURL: character.image?.absoluteString
        )
    }


}

