//
//  CharactersView.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//


import SwiftUI
import SwiftData

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
                                await viewModel.fetchCharacters()
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
                        
                        ForEach(viewModel.filteredCharacters) { character in
                            CharacterCell(character: character)
                                .onAppear {
                                    guard
                                        character.id == viewModel.filteredCharacters.last?.id,
                                        viewModel.nextPageURL != nil,
                                        !viewModel.isLoadingNextPage,
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
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search characters"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker(
                            "Sort by",
                            selection: $viewModel.selectedSort
                        ) {
                            ForEach(
                                CharactersViewModel.SortOption.allCases
                            ) { option in
                                Text(option.rawValue)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.down.up")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker(
                            "Status",
                            selection: $viewModel.selectedStatus
                        ) {
                            ForEach(
                                CharactersViewModel.StatusFilter.allCases
                            ) { status in
                                Text(status.rawValue)
                                    .tag(status)
                            }
                        }
                    } label: {
                        Label(
                            "Filter",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                    }
                }
            }


        }
        .task {
            await viewModel.fetchCharacters()
        }
    }
}

#Preview {
    @Previewable @State var modelContext = ModelContext(
        try! ModelContainer(for: CachedCharacter.self)
    )

    let apiClient = APIClient()
    let localStore = CharactersLocalStore(modelContext: modelContext)

    let repository = CharactersRepositoryImpl(
        apiClient: apiClient,
        localStore: localStore
    )

    CharactersView(repository: repository)
}


