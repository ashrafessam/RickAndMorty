//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Ashraf on 20/10/2026.
//

import SwiftUI
import Kingfisher

struct CharacterDetailView: View {
    
    let character: Character
    
    @State private var viewModel: CharacterDetailViewModel
    
    init(character: Character,repository: any EpisodesRepository) {
            self.character = character
            _viewModel = State(
                initialValue: CharacterDetailViewModel(
                    character: character,
                    repository: repository
                )
            )
        }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                KFImage(character.image)
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text(character.name)
                    .font(.largeTitle.bold())
                
                Label {
                    Text(character.status.rawValue)
                } icon: {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                }
                .font(.headline)
                
                Group {
                    detailRow(title: "Species", value: character.species)
                    detailRow(title: "Gender", value: character.gender)
                    detailRow(title: "Origin", value: character.origin.name)
                    detailRow(title: "Current Location", value: character.location.name)
                }
                episodesSection
            }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEpisodes()
        }
    }
    
    private var statusColor: Color {
        switch character.status {
        case .alive:
                .green
        case .dead:
                .red
        case .unknown:
                .gray
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.body.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodes")
                .font(.title2.bold())

            if viewModel.isLoading {
                HStack {
                    ProgressView()
                    Text("Loading episodes...")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView {
                    Label(
                        "Couldn't Load Episodes",
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadEpisodes()
                        }
                    }
                }
            } else if viewModel.episodes.isEmpty {
                ContentUnavailableView(
                    "No Episodes",
                    systemImage: "tv",
                    description: Text("No episodes are available for this character.")
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.episodes) { episode in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(episode.name)
                                .font(.headline)

                            Text(episode.code)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)

                            Text(episode.airDate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            .thinMaterial,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                }
            }
        }
    }

}

#Preview {
    NavigationStack {
        CharacterDetailView(
            character: Character(
                id: 1,
                name: "Rick Sanchez",
                status: .alive,
                species: "Human",
                gender: "Male",
                origin: .init(name: "Earth (C-137)"),
                location: .init(name: "Citadel of Ricks"),
                image: URL(
                    string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
                ),
                episode: []
            ),
            repository: EpisodesRepositoryImpl(
                apiClient: APIClient()
            )
        )
    }
}
