//
//  Review.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation

struct Review: Codable, Identifiable, Hashable {
    let id: UUID
    let place_id: UUID
    let user_id: UUID
    let rating: Int
    let comment: String?
    let created_at: Date?
}

struct NewReview: Codable {
    let place_id: UUID
    let user_id: UUID
    let rating: Int
    let comment: String?
}
