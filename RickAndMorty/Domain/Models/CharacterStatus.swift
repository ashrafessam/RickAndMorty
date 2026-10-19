//
//  CharacterStatus.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

enum CharacterStatus: String, Decodable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}
