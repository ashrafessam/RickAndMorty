//
//  Character.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

struct Character: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: String
    let origin: Place
    let location: Place
    let image: URL?
    let episode: [String]

    struct Place: Hashable, Decodable {
        let name: String
    }
}
