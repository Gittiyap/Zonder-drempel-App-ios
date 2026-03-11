//
//  PlacePhoto.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation

struct PlacePhoto: Codable, Identifiable, Equatable {
    let id: UUID
    let place_id: UUID
    let category: String
    let storage_path: String
    let created_at: Date?
}
