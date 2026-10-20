//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    private let apiClient = APIClient()
    var body: some Scene {
        WindowGroup {
            CharactersView(repository: CharactersRepositoryImpl(apiClient: apiClient))
        }
    }
}
