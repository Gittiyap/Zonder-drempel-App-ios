//
//  PlaceActionStateViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation
import Combine

@MainActor
final class PlaceActionStateViewModel: ObservableObject {
    @Published var isFavorite = false
    @Published var isSaved = false
    @Published var errorMessage: String?

    private let favoritesRepo = FavoritePlacesRepository()
    private let savedRepo = SavedPlacesRepository()

    func load(userId: UUID, placeId: UUID) async {
        do {
            async let favoritesTask = favoritesRepo.fetchFavorites(userId: userId)
            async let savedTask = savedRepo.fetchSaved(userId: userId)

            let favorites = try await favoritesTask
            let saved = try await savedTask

            isFavorite = favorites.contains(where: { $0.place_id == placeId })
            isSaved = saved.contains(where: { $0.place_id == placeId })
            errorMessage = nil
        } catch {
            errorMessage = "Actiestatus laden mislukt: \(error.localizedDescription)"
        }
    }

    func toggleFavorite(userId: UUID, placeId: UUID) async {
        do {
            if isFavorite {
                try await favoritesRepo.removeFavorite(userId: userId, placeId: placeId)
                isFavorite = false
            } else {
                try await favoritesRepo.addFavorite(userId: userId, placeId: placeId)
                isFavorite = true
            }
            errorMessage = nil
        } catch {
            errorMessage = "Favoriet bijwerken mislukt: \(error.localizedDescription)"
        }
    }

    func toggleSaved(userId: UUID, placeId: UUID) async {
        do {
            if isSaved {
                try await savedRepo.removeSaved(userId: userId, placeId: placeId)
                isSaved = false
            } else {
                try await savedRepo.addSaved(userId: userId, placeId: placeId)
                isSaved = true
            }
            errorMessage = nil
        } catch {
            errorMessage = "Opgeslagen locatie bijwerken mislukt: \(error.localizedDescription)"
        }
    }
}
