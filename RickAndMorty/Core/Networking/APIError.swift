//
//  APIError.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case emptyResponse
}
