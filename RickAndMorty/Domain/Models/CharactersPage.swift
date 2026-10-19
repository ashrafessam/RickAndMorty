//
//  CharactersPage.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

struct CharactersPage: Decodable {
    let info: Info
    let results: [Character]
    
    struct Info: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
}
