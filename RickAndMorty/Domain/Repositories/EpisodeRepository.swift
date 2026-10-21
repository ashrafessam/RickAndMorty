//
//  EpisodeRepository.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

@MainActor
protocol EpisodesRepository {
    func fetchEpisodes(from urls: [URL]) async throws -> [Episode]
}
