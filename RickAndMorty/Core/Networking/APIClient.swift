//
//  APIClient.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T
}

final class APIClient: APIClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(
        from url: URL,
        as type: T.Type
    ) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        guard !data.isEmpty else {
            throw APIError.emptyResponse
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
