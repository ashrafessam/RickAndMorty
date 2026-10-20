//
//  RickAndMortyTests.swift
//  RickAndMortyTests
//
//  Created by Ashraf on 19/10/2026.
//
import Foundation
import Testing
@testable import RickAndMorty

@Suite(.serialized)
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
    
    
    @Test
    @MainActor
    func apiClientThrowsErrorForServerFailure() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: configuration)
        let apiClient = APIClient(session: session)

        guard let url = URL(string: "https://example.com/character") else {
            Issue.record("Invalid test URL")
            return
        }

        MockURLProtocol.requestHandler = { request in
            guard let requestURL = request.url,
                  let response = HTTPURLResponse(
                      url: requestURL,
                      statusCode: 500,
                      httpVersion: nil,
                      headerFields: nil
                  ) else {
                throw URLError(.badServerResponse)
            }

            return (response, Data("Server error".utf8))
        }

        do {
            let _ = try await apiClient.request(
                from: url,
                as: CharactersPage.self
            )

            Issue.record("Expected HTTP 500 error, but request succeeded")
        } catch let error as APIError {
            if case .httpError(statusCode: 500) = error {
                // expected
            } else {
                Issue.record("Unexpected APIError: \(error)")
            }
        }
    }
    
    
    @Test
    @MainActor
    func apiClientThrowsErrorForInvalidJSON() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: configuration)
        let apiClient = APIClient(session: session)

        guard let url = URL(string: "https://example.com/character") else {
            Issue.record("Invalid test URL")
            return
        }

        MockURLProtocol.requestHandler = { request in
            guard let requestURL = request.url,
                  let response = HTTPURLResponse(
                      url: requestURL,
                      statusCode: 200,
                      httpVersion: nil,
                      headerFields: ["Content-Type": "application/json"]
                  ) else {
                throw URLError(.badServerResponse)
            }

            return (response, Data("{ invalid json }".utf8))
        }

        do {
            let _ = try await apiClient.request(
                from: url,
                as: CharactersPage.self
            )

            Issue.record("Expected decoding error, but request succeeded")
        } catch let error as APIError {
            if case .decodingError = error {
                // expected
            } else {
                Issue.record("Unexpected APIError: \(error)")
            }
        }
    }
    
    @Test
    @MainActor
    func viewModelLoadsCharactersSuccessfully() async throws {
        let character = Character(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: Character.Place(name: "Earth (C-137)"),
            location: Character.Place(name: "Citadel of Ricks"),
            image: URL(
                string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
            ),
            episode: ["https://rickandmortyapi.com/api/episode/1"]
        )

        let page = CharactersPage(
            info: .init(
                count: 1,
                pages: 1,
                next: nil,
                prev: nil
            ),
            results: [character]
        )

        let repository = MockCharactersRepository()
        repository.result = .success(page)

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.fetchCharacters()

        #expect(viewModel.characters.count == 1)
        #expect(viewModel.characters.first?.name == "Rick Sanchez")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    
    @Test
    @MainActor
    func viewModelHandlesRepositoryError() async {
        let repository = MockCharactersRepository()
        repository.result = .failure(APIError.emptyResponse)

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.fetchCharacters()

        #expect(viewModel.characters.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test
    @MainActor
    func viewModelRefreshesCharactersSuccessfully() async throws {
        let character = Character(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let page = CharactersPage(
            info: .init(
                count: 1,
                pages: 1,
                next: nil,
                prev: nil
            ),
            results: [character]
        )

        let repository = MockCharactersRepository()
        repository.result = .success(page)

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.refreshCharacters()

        #expect(viewModel.characters.count == 1)
        #expect(viewModel.characters.first?.name == "Morty Smith")
        #expect(viewModel.refreshErrorMessage == nil)
        #expect(viewModel.nextPageURL == nil)
    }
    
    
    @Test
    @MainActor
    func viewModelLoadsNextPageSuccessfully() async throws {
        let firstCharacter = Character(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let secondCharacter = Character(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let nextPageURL = "https://rickandmortyapi.com/api/character?page=2"

        let firstPage = CharactersPage(
            info: .init(
                count: 2,
                pages: 2,
                next: nextPageURL,
                prev: nil
            ),
            results: [firstCharacter]
        )

        let secondPage = CharactersPage(
            info: .init(
                count: 2,
                pages: 2,
                next: nil,
                prev: "https://rickandmortyapi.com/api/character?page=1"
            ),
            results: [secondCharacter]
        )

        let repository = MockCharactersRepository()
        repository.results = [
            .success(firstPage),
            .success(secondPage)
        ]

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.fetchCharacters()
        await viewModel.loadNextPage()

        #expect(viewModel.characters.count == 2)
        #expect(viewModel.characters.map(\.name) == [
            "Rick Sanchez",
            "Morty Smith"
        ])
        #expect(viewModel.nextPageURL == nil)
        #expect(viewModel.paginationErrorMessage == nil)
        #expect(!viewModel.isLoadingNextPage)
    }

    
    @Test
    @MainActor
    func viewModelDoesNotDuplicateCharactersAcrossPages() async throws {
        let rick = Character(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let morty = Character(
            id: 2,
            name: "Morty Smith",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let firstPage = CharactersPage(
            info: .init(
                count: 3,
                pages: 2,
                next: "https://rickandmortyapi.com/api/character?page=2",
                prev: nil
            ),
            results: [rick]
        )

        let secondPage = CharactersPage(
            info: .init(
                count: 3,
                pages: 2,
                next: nil,
                prev: "https://rickandmortyapi.com/api/character?page=1"
            ),
            results: [rick, morty]
        )

        let repository = MockCharactersRepository()
        repository.results = [
            .success(firstPage),
            .success(secondPage)
        ]

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.fetchCharacters()
        await viewModel.loadNextPage()

        #expect(viewModel.characters.count == 2)
        #expect(viewModel.characters.map(\.id) == [1, 2])
    }

    
    @Test
    @MainActor
    func viewModelHandlesNextPageError() async throws {
        let rick = Character(
            id: 1,
            name: "Rick Sanchez",
            status: .alive,
            species: "Human",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: nil,
            episode: []
        )

        let firstPage = CharactersPage(
            info: .init(
                count: 2,
                pages: 2,
                next: "https://rickandmortyapi.com/api/character?page=2",
                prev: nil
            ),
            results: [rick]
        )

        let repository = MockCharactersRepository()
        repository.results = [
            .success(firstPage),
            .failure(APIError.emptyResponse)
        ]

        let viewModel = CharactersViewModel(repository: repository)

        await viewModel.fetchCharacters()
        await viewModel.loadNextPage()

        #expect(viewModel.characters.count == 1)
        #expect(viewModel.characters.first?.name == "Rick Sanchez")
        #expect(viewModel.paginationErrorMessage != nil)
        #expect(!viewModel.isLoadingNextPage)
    }


}
