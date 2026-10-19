//
//  RickAndMortyTests.swift
//  RickAndMortyTests
//
//  Created by Ashraf on 19/10/2026.
//
import Foundation
import Testing
@testable import RickAndMorty

struct RickAndMortyTests {

    @Test
    @MainActor
    func apiClientDecodesSuccessfulResponse() async throws {
        // Arrange
        let expectedJSON = """
        {
            "info": {
                "count": 1,
                "pages": 1,
                "next": null,
                "prev": null
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "status": "Alive",
                    "species": "Human",
                    "gender": "Male",
                    "origin": {
                        "name": "Earth (C-137)"
                    },
                    "location": {
                        "name": "Citadel of Ricks"
                    },
                    "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                    "episode": [
                        "https://rickandmortyapi.com/api/episode/1"
                    ]
                }
            ]
        }
        """

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: sessionConfiguration)
        let apiClient = APIClient(session: session)

        
        
        guard let url = URL(string: "https://example.com/character") else {
            Issue.record("Invalid test URL")
            return
        }

        MockURLProtocol.requestHandler = { request in
            guard let requestURL = request.url else {
                throw URLError(.badURL)
            }

            guard let response = HTTPURLResponse(
                url: requestURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            ) else {
                throw URLError(.badServerResponse)
            }

            return (response, Data(expectedJSON.utf8))
        }


        // Act
        let page = try await apiClient.request(
            from: url,
            as: CharactersPage.self
        )

        // Assert
        #expect(page.results.count == 1)
        #expect(page.results.first?.name == "Rick Sanchez")
        #expect(page.results.first?.status == .alive)
    }
}
