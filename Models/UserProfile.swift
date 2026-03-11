//
//  UserProfile.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation

struct UserProfile: Codable, Identifiable, Hashable {
    let id: UUID
    let email: String?
    let avatar_path: String?
    let created_at: Date?
}

struct UpsertUserProfile: Codable {
    let id: UUID
    let email: String?
    let avatar_path: String?
}
