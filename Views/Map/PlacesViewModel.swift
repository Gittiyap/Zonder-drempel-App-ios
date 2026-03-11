//
//  PlacesViewModel.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import Foundation
import Combine

@MainActor
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repo = PlacesRepository()

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            places = try await repo.fetchPlaces()
            errorMessage = nil
        } catch {
            errorMessage = "Kon locaties niet laden."
        }
    }
}
