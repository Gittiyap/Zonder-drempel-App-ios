//
//  POIBottomSheetView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import SwiftUI

struct POIBottomSheetView: View {
    let poi: POI

    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var auth: AuthViewModel

    private let placesRepo = PlacesRepository()

    @State private var isClaiming = false
    @State private var claimError: String? = nil
    @State private var claimedPlace: Place? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            header

            Divider()
                .overlay(Color.white.opacity(0.12))

            Button {
                openInAppleMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "map")
            }
            .buttonStyle(ZDPrimaryButtonStyle())

            if auth.isAdmin() {
                adminSection
            }

            Text("Tip: Admin kan deze POI omzetten naar een Zonder Drempels-locatie met labels en foto's.")
                .font(.footnote)
                .foregroundStyle(ZDTheme.textSecondary)

            Spacer(minLength: 0)
        }
        .padding(ZDTheme.spacingM)
        .navigationTitle("POI")
        .navigationBarTitleDisplayMode(.inline)
        .presentationBackground(ZDTheme.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
            Text(poi.name)
                .zdTitleStyle()

            Text(poi.type)
                .zdSecondaryStyle()

            if let address = poi.address, !address.isEmpty {
                Text(address)
                    .zdSecondaryStyle()
            } else {
                Text("Adres onbekend")
                    .zdSecondaryStyle()
            }
        }
    }

    private var adminSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Button {
                Task { await claimPOI() }
            } label: {
                Label(isClaiming ? "Claimen..." : "Maak Zonder Drempels locatie", systemImage: "plus.circle")
            }
            .buttonStyle(ZDAccentButtonStyle())
            .disabled(isClaiming)

            if let claimError {
                Text(claimError)
                    .foregroundStyle(ZDTheme.error)
                    .padding()
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous))
            }

            if let claimedPlace {
                NavigationLink {
                    PlaceDetailView(place: claimedPlace)
                } label: {
                    Label("Open nieuwe locatie", systemImage: "arrow.right.circle")
                }
                .buttonStyle(ZDSecondaryButtonStyle())
            }
        }
    }

    private func claimPOI() async {
        isClaiming = true
        defer { isClaiming = false }

        do {
            claimedPlace = try await placesRepo.createPlaceFromPOI(poi)
            claimError = nil
        } catch {
            claimError = "Claimen mislukt: \(error.localizedDescription)"
        }
    }

    private func openInAppleMaps() {
        var components = URLComponents(string: "http://maps.apple.com/")!
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(poi.latitude),\(poi.longitude)"),
            URLQueryItem(name: "q", value: poi.name)
        ]
        if let url = components.url {
            openURL(url)
        }
    }
}
