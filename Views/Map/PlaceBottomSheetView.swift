//
//  PlaceBottomSheetView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import SwiftUI

struct PlaceBottomSheetView: View {
    let place: Place

    @StateObject private var vm = PlaceDetailViewModel()
    @StateObject private var actionVM = PlaceActionStateViewModel()

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.openURL) private var openURL

    private let photosRepo = PhotosRepository()
    private let reviewPhotosRepo = ReviewPhotosRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
                mediaSection
                infoSection
                accessibilitySection
                personalActionsSection
                actionsSection
            }
            .padding(ZDTheme.spacingM)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load(placeId: place.id)

            if let uid = auth.userId {
                await actionVM.load(userId: uid, placeId: place.id)
            }
        }
        .presentationBackground(ZDTheme.background)
    }

    // MARK: - Media

    private var mediaSection: some View {
        Group {
            if combinedPhotoURLs.isEmpty {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: ZDTheme.largeCornerRadius,
                        style: .continuous
                    )
                    .fill(Color.white.opacity(0.06))

                    VStack(spacing: ZDTheme.spacingS) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundStyle(ZDTheme.textSecondary)

                        Text("Nog geen foto's beschikbaar")
                            .font(.footnote)
                            .foregroundStyle(ZDTheme.textSecondary)
                    }
                    .padding()
                }
                .frame(height: 200)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ZDTheme.spacingS) {
                        ForEach(combinedPhotoURLs, id: \.absoluteString) { url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Color.white.opacity(0.06)
                                        ProgressView()
                                            .tint(ZDTheme.accent)
                                    }

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()

                                case .failure:
                                    ZStack {
                                        Color.white.opacity(0.06)

                                        VStack(spacing: 8) {
                                            Image(systemName: "photo")
                                                .font(.title2)
                                                .foregroundStyle(ZDTheme.textSecondary)

                                            Text("Foto niet beschikbaar")
                                                .font(.footnote)
                                                .foregroundStyle(ZDTheme.textSecondary)
                                        }
                                    }

                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 280, height: 200)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: ZDTheme.largeCornerRadius,
                                    style: .continuous
                                )
                            )
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
            Text(place.name)
                .zdTitleStyle()

            Text(place.type)
                .zdSecondaryStyle()

            Text(place.address)
                .zdSecondaryStyle()
        }
    }

    // MARK: - Accessibility

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text("Toegankelijkheid")
                .zdHeadlineStyle()

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: ZDTheme.spacingS),
                    GridItem(.flexible(), spacing: ZDTheme.spacingS)
                ],
                spacing: ZDTheme.spacingS
            ) {
                accessibilityBadge(
                    text: "Drempelvrij",
                    isOn: place.is_step_free
                )

                accessibilityBadge(
                    text: "Toilet",
                    isOn: place.has_toilet
                )

                accessibilityBadge(
                    text: "Parkeren",
                    isOn: place.has_parking
                )

                accessibilityBadge(
                    text: "Ruime paden",
                    isOn: place.wide_paths
                )
            }
        }
        .zdCard()
    }

    private func accessibilityBadge(text: String, isOn: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isOn ? "checkmark.seal.fill" : "xmark.seal")
                .foregroundStyle(isOn ? ZDTheme.accent : ZDTheme.textSecondary)

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isOn ? ZDTheme.textPrimary : ZDTheme.textSecondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(
                cornerRadius: ZDTheme.cornerRadius,
                style: .continuous
            )
            .fill(isOn ? ZDTheme.accent.opacity(0.16) : Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: ZDTheme.cornerRadius,
                style: .continuous
            )
            .stroke(
                isOn ? ZDTheme.accent.opacity(0.35) : Color.white.opacity(0.06),
                lineWidth: 1
            )
        )
    }

    // MARK: - Personal Actions

    private var personalActionsSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text("Mijn acties")
                .zdHeadlineStyle()

            if let uid = auth.userId {
                if actionVM.isFavorite {
                    Button {
                        Task {
                            await actionVM.toggleFavorite(userId: uid, placeId: place.id)
                        }
                    } label: {
                        Label("Favoriet", systemImage: "heart.fill")
                    }
                    .buttonStyle(ZDAccentButtonStyle())
                } else {
                    Button {
                        Task {
                            await actionVM.toggleFavorite(userId: uid, placeId: place.id)
                        }
                    } label: {
                        Label("Toevoegen aan favorieten", systemImage: "heart")
                    }
                    .buttonStyle(ZDSecondaryButtonStyle())
                }

                if actionVM.isSaved {
                    Button {
                        Task {
                            await actionVM.toggleSaved(userId: uid, placeId: place.id)
                        }
                    } label: {
                        Label("Opgeslagen", systemImage: "bookmark.fill")
                    }
                    .buttonStyle(ZDAccentButtonStyle())
                } else {
                    Button {
                        Task {
                            await actionVM.toggleSaved(userId: uid, placeId: place.id)
                        }
                    } label: {
                        Label("Locatie opslaan", systemImage: "bookmark")
                    }
                    .buttonStyle(ZDSecondaryButtonStyle())
                }
            } else {
                Text("Log in om deze locatie op te slaan.")
                    .zdSecondaryStyle()
            }
        }
        .zdCard()
    }

    // MARK: - General Actions

    private var actionsSection: some View {
        VStack(spacing: ZDTheme.spacingS) {
            NavigationLink {
                PlaceDetailView(place: place)
            } label: {
                Label("Bekijk details", systemImage: "info.circle")
            }
            .buttonStyle(ZDPrimaryButtonStyle())

            Button {
                openInAppleMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "map")
            }
            .buttonStyle(ZDSecondaryButtonStyle())
        }
    }

    // MARK: - Helpers

    private var combinedPhotoURLs: [URL] {
        let placeURLs = vm.photos.compactMap {
            try? photosRepo.publicURL(for: $0.storage_path)
        }

        let reviewURLs = vm.reviewPhotosByReviewId
            .values
            .flatMap { $0 }
            .compactMap {
                try? reviewPhotosRepo.publicURL(for: $0.storage_path)
            }

        return Array((placeURLs + reviewURLs).prefix(10))
    }

    private func openInAppleMaps() {
        var components = URLComponents(string: "http://maps.apple.com/")!
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(place.latitude),\(place.longitude)"),
            URLQueryItem(name: "q", value: place.name)
        ]

        if let url = components.url {
            openURL(url)
        }
    }
}
