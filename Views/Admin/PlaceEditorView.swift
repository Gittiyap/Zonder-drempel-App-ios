//
//  PlaceEditorView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI
import PhotosUI

struct PlaceEditorView: View {
    enum Mode {
        case new
        case edit(Place)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss

    private let placesRepo = PlacesRepository()
    private let photosRepo = PhotosRepository()

    @State private var name = ""
    @State private var type = ""
    @State private var address = ""
    @State private var latitude = "51.5719"
    @State private var longitude = "4.7683"

    @State private var hasParking = false
    @State private var hasToilet = false
    @State private var stepFree = false
    @State private var widePaths = false

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoCategory: String = "entrance"

    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("Basis") {
                    TextField("Naam", text: $name)
                    TextField("Type", text: $type)
                    TextField("Adres", text: $address)
                }

                Section("Coördinaten") {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)

                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                }

                Section("Toegankelijkheid") {
                    Toggle("Gehandicapten parkeren", isOn: $hasParking)
                    Toggle("Invalidentoilet", isOn: $hasToilet)
                    Toggle("Drempelvrij", isOn: $stepFree)
                    Toggle("Ruime paden", isOn: $widePaths)
                }

                Section("Foto upload") {
                    Picker("Categorie", selection: $photoCategory) {
                        Text("Ingang").tag("entrance")
                        Text("Toilet").tag("toilet")
                        Text("Overig").tag("other")
                    }

                    PhotosPicker("Kies foto", selection: $selectedPhoto, matching: .images)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(ZDTheme.error)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ZDTheme.background)
            .navigationTitle(title)
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                    .foregroundStyle(ZDTheme.textPrimary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Opslaan..." : "Opslaan") {
                        Task { await save() }
                    }
                    .foregroundStyle(ZDTheme.accent)
                    .disabled(isSaving)
                }
            }
            .onAppear {
                preloadIfNeeded()
            }
        }
    }

    private var title: String {
        switch mode {
        case .new: return "Nieuwe locatie"
        case .edit: return "Locatie bewerken"
        }
    }

    private func preloadIfNeeded() {
        guard case .edit(let place) = mode else { return }
        name = place.name
        type = place.type
        address = place.address
        latitude = String(place.latitude)
        longitude = String(place.longitude)
        hasParking = place.has_parking
        hasToilet = place.has_toilet
        stepFree = place.is_step_free
        widePaths = place.wide_paths
    }

    @MainActor
    private func save() async {
        isSaving = true
        defer { isSaving = false }

        do {
            guard let lat = Double(latitude), let lon = Double(longitude) else {
                errorMessage = "Ongeldige coördinaten."
                return
            }

            let place: Place

            switch mode {
            case .new:
                place = try await placesRepo.createPlace(
                    NewPlace(
                        name: name,
                        type: type,
                        address: address,
                        latitude: lat,
                        longitude: lon,
                        has_parking: hasParking,
                        has_toilet: hasToilet,
                        is_step_free: stepFree,
                        wide_paths: widePaths
                    )
                )

            case .edit(let existing):
                var updated = existing
                updated.name = name
                updated.type = type
                updated.address = address
                updated.latitude = lat
                updated.longitude = lon
                updated.has_parking = hasParking
                updated.has_toilet = hasToilet
                updated.is_step_free = stepFree
                updated.wide_paths = widePaths
                try await placesRepo.updatePlace(updated)
                place = updated
            }

            if let selectedPhoto,
               let data = try await selectedPhoto.loadTransferable(type: Data.self) {
                let upload = try await photosRepo.uploadAccessibilityPhoto(
                    placeId: place.id,
                    category: photoCategory,
                    imageData: data
                )

                _ = try await photosRepo.attachPhotoRecord(
                    placeId: place.id,
                    category: photoCategory,
                    storagePath: upload.storagePath
                )
            }

            dismiss()
        } catch {
            errorMessage = "Opslaan mislukt: \(error.localizedDescription)"
        }
    }
}
