//
//  SupabaseService.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()

    private let supabaseURL = URL(string: "https://gsbpfsjfjwxbgeivgtmw.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdzYnBmc2pmand4YmdlaXZndG13Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwMjQxNjEsImV4cCI6MjA4NzYwMDE2MX0.MReT8gQDxd8q1EDTpOExag15HfKBwJyFbjjbj1aOT-Y"

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
