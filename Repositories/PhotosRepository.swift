//
//  PhotosRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Supabase
import UIKit

final class PhotosRepository {
    private let client = SupabaseService.shared.client
    private let bucket = "place-photos"

    func uploadAccessibilityPhoto(
        placeId: UUID,
        category: String,
        imageData: Data
    ) async throws -> (storagePath: String, publicURL: URL) {
        let jpegData = try normalizedJPEGData(from: imageData)

        let fileName = "\(placeId.uuidString)/\(category)-\(UUID().uuidString).jpg"
        let path = fileName

        try await client.storage
            .from(bucket)
            .upload(
                path,
                data: jpegData,
                options: FileOptions(contentType: "image/jpeg", upsert: false)
            )

        let publicURL = try client.storage
            .from(bucket)
            .getPublicURL(path: path)

        return (storagePath: path, publicURL: publicURL)
    }

    func attachPhotoRecord(
        placeId: UUID,
        category: String,
        storagePath: String
    ) async throws -> PlacePhoto {
        struct NewPhoto: Codable {
            let place_id: UUID
            let category: String
            let storage_path: String
        }

        let payload = NewPhoto(
            place_id: placeId,
            category: category,
            storage_path: storagePath
        )

        let inserted: [PlacePhoto] = try await client
            .from("place_photos")
            .insert(payload)
            .select()
            .execute()
            .value

        guard let first = inserted.first else {
            throw NSError(domain: "photo_insert_failed", code: 1)
        }

        return first
    }

    func publicURL(for storagePath: String) throws -> URL {
        try client.storage
            .from(bucket)
            .getPublicURL(path: storagePath)
    }

    private func normalizedJPEGData(from data: Data) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "image_decode_failed", code: 1)
        }

        guard let jpegData = image.jpegData(compressionQuality: 0.82) else {
            throw NSError(domain: "image_jpeg_conversion_failed", code: 2)
        }

        return jpegData
    }
}
