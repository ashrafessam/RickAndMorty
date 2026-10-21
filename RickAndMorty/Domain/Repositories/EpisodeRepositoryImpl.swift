//
//  EpisodesRepositoryImpl.swift
//  RickAndMorty
//
//  Created by Ashraf on 20/10/2026.
//


import Foundation

@MainActor
final class EpisodesRepositoryImpl: EpisodesRepository {
    private let apiClient: any APIClientProtocol

    init(apiClient: any APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchEpisodes(from urls: [URL]) async throws -> [Episode] {
        guard !urls.isEmpty else {
            return []
        }

        let episodeIDs = urls.compactMap { url -> String? in
            url.pathComponents.last
        }

        guard episodeIDs.count == urls.count else {
            throw APIError.invalidURL
        }

        let ids = episodeIDs.joined(separator: ",")
        let endpoint = URL(string: "https://rickandmortyapi.com/api/episode/\(ids)")!

        if urls.count == 1 {
            let episode = try await apiClient.request(
                from: endpoint,
                as: Episode.self
            )
            return [episode]
        }

        return try await apiClient.request(
            from: endpoint,
            as: [Episode].self
        )
    }
}
