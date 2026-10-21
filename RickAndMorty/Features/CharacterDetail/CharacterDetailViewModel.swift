//
//  CharacterDetailViewModel.swift
//  RickAndMorty
//
//  Created by Ashraf on 20/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CharacterDetailViewModel {
    private let repository: any EpisodesRepository
    private let episodeURLs: [URL]

    private(set) var episodes: [Episode] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var hasLoadedEpisodes = false

    init(
        character: Character,
        repository: any EpisodesRepository
    ) {
        self.episodeURLs = character.episode.compactMap(URL.init(string:))
        self.repository = repository
    }

    func loadEpisodes() async {
        guard !hasLoadedEpisodes, !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            episodes = try await repository.fetchEpisodes(from: episodeURLs)
            hasLoadedEpisodes = true
        } catch {
            errorMessage = "Failed to load episodes. Please try again."
        }
    }
}
