//
//  UserProfileRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import Foundation
import Supabase
import UIKit

final class UserProfileRepository {
    private let client = SupabaseService.shared.client
    private let bucket = "profile-photos"

    private struct UpdateUserProfile: Codable {
        let email: String?
        let avatar_path: String?
    }

    func fetchProfile(userId: UUID) async throws -> UserProfile? {
        let profiles: [UserProfile] = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        return profiles.first
    }

    func saveProfile(_ profile: UpsertUserProfile) async throws {
        let existing = try await fetchProfile(userId: profile.id)

        if existing == nil {
            try await insertProfile(profile)
        } else {
            try await updateProfile(profile)
        }
    }

    private func insertProfile(_ profile: UpsertUserProfile) async throws {
        _ = try await client
            .from("user_profiles")
            .insert(profile)
            .execute()
    }

    private func updateProfile(_ profile: UpsertUserProfile) async throws {
        let payload = UpdateUserProfile(
            email: profile.email,
            avatar_path: profile.avatar_path
        )

        _ = try await client
            .from("user_profiles")
            .update(payload)
            .eq("id", value: profile.id.uuidString)
            .execute()
    }

    func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
        guard let image = UIImage(data: imageData),
              let jpegData = image.jpegData(compressionQuality: 0.82) else {
            throw NSError(domain: "avatar_conversion_failed", code: 1)
        }

        let normalizedUserId = userId.uuidString.lowercased()
        let path = "\(normalizedUserId)/avatar.jpg"
        
        try await client.storage
            .from(bucket)
            .upload(
                path,
                data: jpegData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )

        return path
    }

    func publicURL(for storagePath: String) throws -> URL {
        try client.storage
            .from(bucket)
            .getPublicURL(path: storagePath)
    }
}
