//
//  ReviewsRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation
import Supabase

final class ReviewsRepository {
    private let client = SupabaseService.shared.client

    func fetchReviews(placeId: UUID) async throws -> [Review] {
        try await client
            .from("reviews")
            .select()
            .eq("place_id", value: placeId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func addReview(_ review: NewReview) async throws {
        _ = try await client
            .from("reviews")
            .insert(review)
            .execute()
    }

    func addReviewReturning(_ review: NewReview) async throws -> Review {
        let inserted: [Review] = try await client
            .from("reviews")
            .insert(review)
            .select()
            .execute()
            .value

        guard let first = inserted.first else {
            throw NSError(domain: "review_insert_failed", code: 1)
        }

        return first
    }
}
