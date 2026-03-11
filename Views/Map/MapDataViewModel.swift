//
//  MapDataViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import Foundation
import Combine

@MainActor
final class MapDataViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var pois: [POI] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let placesRepo = PlacesRepository()
    private let poisRepo = POIsRepository()

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let p1 = placesRepo.fetchPlaces()
            async let p2 = poisRepo.fetchPOIs()
            let loadedPlaces = try await p1
            let loadedPOIs = try await p2

            places = loadedPlaces

            let claimedPOIIds = Set(
                loadedPlaces.compactMap { $0.poi_id }
            )

            pois = loadedPOIs.filter { poi in
                !claimedPOIIds.contains(poi.id)
            }
            errorMessage = nil
        }catch {
            errorMessage = "Kon data niet laden: \(String(describing: error))"
        }
    }
}
