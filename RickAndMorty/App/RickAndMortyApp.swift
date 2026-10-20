//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import SwiftUI
import SwiftData

@main
struct RickAndMortyApp: App {
    var body: some Scene {
        WindowGroup {
            CharactersRootView()
        }
        .modelContainer(for: CachedCharacter.self)
    }
}

private struct CharactersRootView: View {
    @Environment(\.modelContext) private var modelContext

    private let apiClient = APIClient()

    var body: some View {
        CharactersView(
            repository: CharactersRepositoryImpl(
                apiClient: apiClient,
                localStore: CharactersLocalStore(
                    modelContext: modelContext
                )
            )
        )
    }
}
