//
//  FavoritePlacesRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation
import Supabase

final class FavoritePlacesRepository {
    private let client = SupabaseService.shared.client

    func fetchFavorites(userId: UUID) async throws -> [FavoritePlace] {
        try await client
            .from("favorite_places")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func addFavorite(userId: UUID, placeId: UUID) async throws {
        struct Payload: Codable {
            let user_id: UUID
            let place_id: UUID
        }

        _ = try await client
            .from("favorite_places")
            .insert(Payload(user_id: userId, place_id: placeId))
            .execute()
    }

    func removeFavorite(userId: UUID, placeId: UUID) async throws {
        _ = try await client
            .from("favorite_places")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("place_id", value: placeId.uuidString)
            .execute()
    }
}
