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
                    ContentUnavailableView {
                        Label(
                            "Something went wrong",
                            systemImage: "exclamationmark.triangle"
                        )
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.retryInitialLoading()
                            }
                        }
                    }
                } else if viewModel.characters.isEmpty {
                    ContentUnavailableView(
                        "No characters found",
                        systemImage: "person.slash",
                        description: Text(
                            "There are no characters to display."
                        )
                    )
                } else {
                    List {
                        if let refreshError = viewModel.refreshErrorMessage {
                            Section {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label(
                                        refreshError,
                                        systemImage: "exclamationmark.triangle"
                                    )
                                    
                                    Button("Try Refresh Again") {
                                        Task {
                                            await viewModel.refreshCharacters()
                                        }
                                    }
                                }
                            }
                        }
                        
                        ForEach(viewModel.characters) { character in
                            CharacterCell(character: character)
                                .onAppear {
                                    guard
                                        viewModel.characters.suffix(5)
                                            .contains(where: { $0.id == character.id }),
                                        viewModel.paginationErrorMessage == nil
                                            else {
                                        return
                                    }
                                    
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                        }
                        
                        if viewModel.isLoadingNextPage {
                            HStack {
                                Spacer()
                                ProgressView("Loading more characters...")
                                Spacer()
                            }
                        } else if let paginationError =
                                    viewModel.paginationErrorMessage {
                            VStack(spacing: 8) {
                                Text(paginationError)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                
                                Button("Retry Loading More") {
                                    Task {
                                        await viewModel.loadNextPage()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .refreshable {
                        await viewModel.refreshCharacters()
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


