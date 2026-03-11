//
//  ReviewPhotosRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation
import Supabase
import UIKit

final class ReviewPhotosRepository {
    private let client = SupabaseService.shared.client
    private let bucket = "review-photos"

    func upload(reviewId: UUID, imageData: Data) async throws -> String {
        let jpegData = try normalizedJPEGData(from: imageData)

        let path = "\(reviewId.uuidString)/\(UUID().uuidString).jpg"

        try await client.storage
            .from(bucket)
            .upload(
                path,
                data: jpegData,
                options: FileOptions(contentType: "image/jpeg", upsert: false)
            )

        return path
    }

    func insertPhotoRecord(_ payload: NewReviewPhoto) async throws {
        _ = try await client
            .from("review_photos")
            .insert(payload)
            .execute()
    }

    func fetchPhotos(reviewId: UUID) async throws -> [ReviewPhoto] {
        try await client
            .from("review_photos")
            .select()
            .eq("review_id", value: reviewId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
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
