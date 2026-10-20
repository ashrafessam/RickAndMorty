//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//


import SwiftUI

struct CharactersView: View {
    @State private var viewModel: CharactersViewModel
    
    init(repository: any CharactersRepository) {
        _viewModel = State(
            initialValue: CharactersViewModel(repository: repository)
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading characters...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.characters.isEmpty {
                    ContentUnavailableView(
                        "No characters found",
                        systemImage: "person.slash",
                        description: Text("There are no characters to display.")
                    )
                } else {
                    List(viewModel.characters) { character in
                        CharacterCell(character: character)
                    }
                }
            }
            .navigationTitle("Characters")
        }
        .task {
            await viewModel.fetchCharacters()
        }
    }
}



#Preview {
    let apiClient = APIClient()
    let repository = CharactersRepositoryImpl(apiClient: apiClient)
    
    CharactersView(repository: repository)
}

