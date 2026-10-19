//
//  Episode.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

struct Episode: Identifiable, Hashable, Decodable {
    let id: Int
    let name: String
    let airDate: String
    let code: String

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case code = "episode"
    }
}
