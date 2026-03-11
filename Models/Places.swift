//
//  Places.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation

struct Place: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var type: String
    var address: String
    var latitude: Double
    var longitude: Double

    var has_parking: Bool
    var has_toilet: Bool
    var is_step_free: Bool
    var wide_paths: Bool

    var created_at: Date?
    var poi_id: UUID?
}

struct NewPlace: Codable {
    var name: String
    var type: String
    var address: String
    var latitude: Double
    var longitude: Double
    var has_parking: Bool
    var has_toilet: Bool
    var is_step_free: Bool
    var wide_paths: Bool
}
