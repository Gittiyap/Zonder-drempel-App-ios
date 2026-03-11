//
//  ReviewPhoto.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation

struct ReviewPhoto: Codable, Identifiable, Hashable {
    let id: UUID
    let review_id: UUID
    let place_id: UUID
    let user_id: UUID
    let storage_path: String
    let created_at: Date?
}

struct NewReviewPhoto: Codable {
    let review_id: UUID
    let place_id: UUID
    let user_id: UUID
    let storage_path: String
}
