//
//  POIsRepository.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation
import Supabase

final class POIsRepository {
    private let client = SupabaseService.shared.client

    func fetchPOIs() async throws -> [POI] {
        try await client
            .from("pois")
            .select("id,name,type,address,latitude,longitude,data_source,external_id,created_at")
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
