//
//  PlacesRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Supabase

final class PlacesRepository {
    private let client = SupabaseService.shared.client

    func fetchPlaces() async throws -> [Place] {
        try await client
            .from("places")
            .select("id,name,type,address,latitude,longitude,has_parking,has_toilet,is_step_free,wide_paths,created_at,poi_id")
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func fetchPlacesByIds(ids: [UUID]) async throws -> [Place] {
        guard !ids.isEmpty else { return [] }

        let allPlaces = try await fetchPlaces()
        let idSet = Set(ids)

        return allPlaces.filter { idSet.contains($0.id) }
    }

    func fetchPhotos(placeId: UUID) async throws -> [PlacePhoto] {
        try await client
            .from("place_photos")
            .select()
            .eq("place_id", value: placeId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func createPlace(_ place: NewPlace) async throws -> Place {
        let inserted: [Place] = try await client
            .from("places")
            .insert(place)
            .select()
            .execute()
            .value

        guard let first = inserted.first else {
            throw NSError(domain: "insert_failed", code: 1)
        }

        return first
    }

    func createPlaceFromPOI(_ poi: POI) async throws -> Place {
        struct NewPlaceFromPOI: Codable {
            let poi_id: UUID
            let name: String
            let type: String
            let address: String
            let latitude: Double
            let longitude: Double
            let has_parking: Bool
            let has_toilet: Bool
            let is_step_free: Bool
            let wide_paths: Bool
        }

        let payload = NewPlaceFromPOI(
            poi_id: poi.id,
            name: poi.name,
            type: poi.type,
            address: poi.address ?? "",
            latitude: poi.latitude,
            longitude: poi.longitude,
            has_parking: false,
            has_toilet: false,
            is_step_free: false,
            wide_paths: false
        )

        let inserted: [Place] = try await client
            .from("places")
            .insert(payload)
            .select()
            .execute()
            .value

        guard let first = inserted.first else {
            throw NSError(domain: "create_from_poi_failed", code: 1)
        }

        return first
    }

    func updatePlace(_ place: Place) async throws {
        _ = try await client
            .from("places")
            .update(place)
            .eq("id", value: place.id.uuidString)
            .execute()
    }

    func deletePlace(id: UUID) async throws {
        _ = try await client
            .from("places")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
