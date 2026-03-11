//
//  SavedPlacesRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation
import Supabase

final class SavedPlacesRepository {
    private let client = SupabaseService.shared.client

    func fetchSaved(userId: UUID) async throws -> [SavedPlace] {
        try await client
            .from("saved_places")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func addSaved(userId: UUID, placeId: UUID) async throws {
        struct Payload: Codable {
            let user_id: UUID
            let place_id: UUID
        }

        _ = try await client
            .from("saved_places")
            .insert(Payload(user_id: userId, place_id: placeId))
            .execute()
    }

    func removeSaved(userId: UUID, placeId: UUID) async throws {
        _ = try await client
            .from("saved_places")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("place_id", value: placeId.uuidString)
            .execute()
    }
}
