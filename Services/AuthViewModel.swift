//
//  AuthViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Supabase
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthed: Bool = false
    @Published var userEmail: String? = nil
    @Published var userId: UUID? = nil
    @Published var errorMessage: String? = nil

    private let client = SupabaseService.shared.client

    init() {
        Task { await refreshSession() }
    }

    func refreshSession() async {
        do {
            let session = try await client.auth.session

            if session.isExpired {
                isAuthed = false
                userEmail = nil
                userId = nil
                return
            }

            isAuthed = true
            userEmail = session.user.email
            userId = session.user.id
            errorMessage = nil
        } catch {
            isAuthed = false
            userEmail = nil
            userId = nil
        }
    }

    func signUp(email: String, password: String) async {
        do {
            _ = try await client.auth.signUp(email: email, password: password)
            await refreshSession()
            errorMessage = nil
        } catch {
            errorMessage = "Account aanmaken mislukt: \(error.localizedDescription)"
        }
    }

    func signIn(email: String, password: String) async {
        do {
            _ = try await client.auth.signIn(email: email, password: password)
            await refreshSession()
            errorMessage = nil
        } catch {
            errorMessage = "Inloggen mislukt: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
        } catch {
            errorMessage = "Uitloggen mislukt: \(error.localizedDescription)"
        }
        await refreshSession()
    }

    func isAdmin() -> Bool {
        guard let email = userEmail?.lowercased() else { return false }
        return ["admin@zonderdrempels.nl", "thomas@zonderdrempels.nl"].contains(email)
    }
}
