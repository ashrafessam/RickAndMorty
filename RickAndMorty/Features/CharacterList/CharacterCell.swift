//
//  CharacterCell.swift
//  RickAndMorty
//
//  Created by Ashraf on 19/10/2026.
//

import SwiftUI
import Kingfisher


struct CharacterCell: View {
    @Environment(\.displayScale) private var displayScale
    
    let character: Character
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(character.image)
                .placeholder {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 80, height: 80)))
                .scaleFactor(displayScale)
                .cancelOnDisappear(true)
                .retry(maxCount: 4, interval: .accumulated(3))
                .onFailure { error in
                    print("Image failed:", error)
                }
                .onFailureView {
                    Image(systemName: "person.crop.square")
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                        .foregroundStyle(.secondary)
                }
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)
                
                Text(character.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(character.status.rawValue.capitalized)
                        .font(.caption)
                }
                
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
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
}


#Preview {
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
        episode: [
            "https://rickandmortyapi.com/api/episode/1"
        ]
    )
    
    CharacterCell(character: character)
}
