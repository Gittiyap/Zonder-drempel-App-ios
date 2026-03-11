//
//  PlaceDetailViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Combine

@MainActor
final class PlaceDetailViewModel: ObservableObject {
    @Published var photos: [PlacePhoto] = []
    @Published var reviews: [Review] = []
    @Published var reviewPhotosByReviewId: [UUID: [ReviewPhoto]] = [:]
    @Published var errorMessage: String? = nil

    private let placesRepo = PlacesRepository()
    private let reviewsRepo = ReviewsRepository()
    private let reviewPhotosRepo = ReviewPhotosRepository()

    func load(placeId: UUID) async {
        do {
            async let loadedPhotos = placesRepo.fetchPhotos(placeId: placeId)
            async let loadedReviews = reviewsRepo.fetchReviews(placeId: placeId)

            photos = try await loadedPhotos
            reviews = try await loadedReviews

            await loadAllReviewPhotos()

            errorMessage = nil
        } catch {
            errorMessage = "Kon details niet laden: \(error.localizedDescription)"
        }
    }

    func addReviewWithPhotos(
        placeId: UUID,
        userId: UUID,
        rating: Int,
        comment: String?,
        photos: [Data]
    ) async throws {
        let created = try await reviewsRepo.addReviewReturning(
            NewReview(
                place_id: placeId,
                user_id: userId,
                rating: rating,
                comment: comment
            )
        )

        for data in photos {
            let path = try await reviewPhotosRepo.upload(
                reviewId: created.id,
                imageData: data
            )

            try await reviewPhotosRepo.insertPhotoRecord(
                NewReviewPhoto(
                    review_id: created.id,
                    place_id: placeId,
                    user_id: userId,
                    storage_path: path
                )
            )
        }

        reviews = try await reviewsRepo.fetchReviews(placeId: placeId)
        await loadAllReviewPhotos()
    }

    private func loadAllReviewPhotos() async {
        var result: [UUID: [ReviewPhoto]] = [:]

        for review in reviews {
            do {
                let photos = try await reviewPhotosRepo.fetchPhotos(reviewId: review.id)
                result[review.id] = photos
            } catch {
                result[review.id] = []
            }
        }

        reviewPhotosByReviewId = result
    }
}
