//
//  POI.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation

struct POI: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var type: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var data_source: String?
    var external_id: String?
    var created_at: Date?
}
