//
//  AccountViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation
import Combine
import Supabase

@MainActor
final class AccountViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var myReviews: [Review] = []
    @Published var favoritePlaceIds: [UUID] = []
    @Published var savedPlaceIds: [UUID] = []
    @Published var favoritePlaces: [Place] = []
    @Published var savedPlaces: [Place] = []
    @Published var errorMessage: String?
    @Published var isUploadingAvatar = false

    private let profileRepo = UserProfileRepository()
    private let reviewsRepo = ReviewsRepository()
    private let favoritesRepo = FavoritePlacesRepository()
    private let savedRepo = SavedPlacesRepository()
    private let placesRepo = PlacesRepository()

    func load(userId: UUID) async {
        do {
            async let profileTask = profileRepo.fetchProfile(userId: userId)
            async let favoritesTask = favoritesRepo.fetchFavorites(userId: userId)
            async let savedTask = savedRepo.fetchSaved(userId: userId)

            let loadedProfile = try await profileTask
            let favorites = try await favoritesTask
            let saved = try await savedTask

            let loadedFavoriteIds = favorites.map(\.place_id)
            let loadedSavedIds = saved.map(\.place_id)

            profile = loadedProfile
            favoritePlaceIds = loadedFavoriteIds
            savedPlaceIds = loadedSavedIds

            async let favoritePlacesTask = placesRepo.fetchPlacesByIds(ids: loadedFavoriteIds)
            async let savedPlacesTask = placesRepo.fetchPlacesByIds(ids: loadedSavedIds)

            favoritePlaces = try await favoritePlacesTask
            savedPlaces = try await savedPlacesTask

            errorMessage = nil
        } catch {
            errorMessage = "Accountgegevens laden mislukt: \(error.localizedDescription)"
        }
    }

    func loadMyReviews(userId: UUID) async {
        do {
            myReviews = try await fetchReviewsByUser(userId: userId)
            errorMessage = nil
        } catch {
            errorMessage = "Reviews laden mislukt: \(error.localizedDescription)"
        }
    }

    func uploadAvatar(userId: UUID, email: String?, imageData: Data) async {
        isUploadingAvatar = true
        defer { isUploadingAvatar = false }

        do {
            let avatarPath: String

            do {
                avatarPath = try await profileRepo.uploadAvatar(userId: userId, imageData: imageData)
                print("Avatar upload gelukt:", avatarPath)
            } catch {
                errorMessage = "Storage upload mislukt: \(error.localizedDescription)"
                print("Storage upload fout:", error)
                return
            }

            do {
                try await profileRepo.saveProfile(
                    UpsertUserProfile(
                        id: userId,
                        email: email,
                        avatar_path: avatarPath
                    )
                )
                print("Profiel opslaan gelukt")
            } catch {
                errorMessage = "Profiel opslaan mislukt: \(error.localizedDescription)"
                print("Profiel opslaan fout:", error)
                return
            }

            profile = try await profileRepo.fetchProfile(userId: userId)
            errorMessage = nil
        } catch {
            errorMessage = "Profielfoto uploaden mislukt: \(error.localizedDescription)"
            print("Algemene avatar fout:", error)
        }
    }
    private func fetchReviewsByUser(userId: UUID) async throws -> [Review] {
        let client = SupabaseService.shared.client

        return try await client
            .from("reviews")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
