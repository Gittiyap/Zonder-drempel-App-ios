//
//  FavoritePlace.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation

struct FavoritePlace: Codable, Identifiable, Hashable {
    let id: UUID
    let user_id: UUID
    let place_id: UUID
    let created_at: Date?
}
