//
//  PlaceDetailView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI

struct PlaceDetailView: View {
    let place: Place

    @StateObject private var vm = PlaceDetailViewModel()
    @StateObject private var actionVM = PlaceActionStateViewModel()

    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.openURL) private var openURL

    private let photosRepo = PhotosRepository()
    private let reviewPhotosRepo = ReviewPhotosRepository()

    @State private var showingAddReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ZDTheme.spacingL) {
                headerSection
                quickActionsSection
                accessibilitySection
                combinedPhotosSection
                reviewsSection
            }
            .padding(ZDTheme.spacingM)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ZDTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await vm.load(placeId: place.id)

            if let uid = auth.userId {
                await actionVM.load(userId: uid, placeId: place.id)
            }
        }
        .sheet(isPresented: $showingAddReview) {
            if let uid = auth.userId {
                AddReviewView(placeId: place.id, userId: uid) { rating, comment, photoDatas in
                    do {
                        try await vm.addReviewWithPhotos(
                            placeId: place.id,
                            userId: uid,
                            rating: rating,
                            comment: comment,
                            photos: photoDatas
                        )
                    } catch {
                        vm.errorMessage = "Review opslaan mislukt: \(error.localizedDescription)"
                    }
                }
                .presentationBackground(ZDTheme.background)
            } else {
                Text("Log in om een review toe te voegen.")
                    .padding()
                    .foregroundStyle(ZDTheme.textPrimary)
                    .background(ZDTheme.background)
            }
        }
        .overlay(alignment: .top) {
            VStack(spacing: 8) {
                if let message = vm.errorMessage {
                    Text(message)
                        .foregroundStyle(ZDTheme.textPrimary)
                        .padding()
                        .background(Color.red.opacity(0.18))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ZDTheme.cornerRadius,
                                style: .continuous
                            )
                        )
                }

                if let message = actionVM.errorMessage {
                    Text(message)
                        .foregroundStyle(ZDTheme.textPrimary)
                        .padding()
                        .background(Color.red.opacity(0.18))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ZDTheme.cornerRadius,
                                style: .continuous
                            )
                        )
                }
            }
            .padding()
        }
        .zdScreenBackground()
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text(place.name)
                .zdTitleStyle()

            Text(place.type)
                .zdSecondaryStyle()

            Text(place.address)
                .zdSecondaryStyle()

            Button {
                openInAppleMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "map")
            }
            .buttonStyle(ZDPrimaryButtonStyle())
        }
        .zdCard()
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            Text("Mijn acties")
                .zdHeadlineStyle()

            if let uid = auth.userId {
                HStack(spacing: ZDTheme.spacingS) {
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
                    }                }
            } else {
                Text("Log in om locaties op te slaan of als favoriet te markeren.")
                    .zdSecondaryStyle()
            }
        }
        .zdCard()
    }

    // MARK: - Accessibility

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            Text("Toegankelijkheid")
                .zdHeadlineStyle()

            ZDStatusRow(title: "Drempelvrij", isOn: place.is_step_free)
            ZDStatusRow(title: "Invalidentoilet", isOn: place.has_toilet)
            ZDStatusRow(title: "Gehandicapten parkeren", isOn: place.has_parking)
            ZDStatusRow(title: "Ruime paden", isOn: place.wide_paths)
        }
        .zdCard()
    }

    // MARK: - Combined Photos

    private var combinedPhotosSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            Text("Foto's van toegankelijkheid")
                .zdHeadlineStyle()

            if combinedPhotoURLs.isEmpty {
                Text("Nog geen foto's.")
                    .zdSecondaryStyle()
            } else {
                ForEach(combinedPhotoURLs, id: \.absoluteString) { url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(ZDTheme.accent)
                                .frame(maxWidth: .infinity, minHeight: 180)

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

                                    Text("Foto kon niet geladen worden")
                                        .font(.footnote)
                                        .foregroundStyle(ZDTheme.textSecondary)
                                }
                            }

                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 180)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: ZDTheme.cornerRadius,
                            style: .continuous
                        )
                    )
                }
            }
        }
        .zdCard()
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            HStack {
                Text("Reviews")
                    .zdHeadlineStyle()

                Spacer()

                if auth.isAuthed {
                    Button {
                        showingAddReview = true
                    } label: {
                        Label("Toevoegen", systemImage: "plus")
                    }
                    .buttonStyle(ZDAccentButtonStyle())
                }
            }

            if vm.reviews.isEmpty {
                Text("Nog geen reviews.")
                    .zdSecondaryStyle()
            } else {
                ForEach(vm.reviews) { review in
                    reviewCard(for: review)
                }
            }
        }
        .zdCard()
    }

    private func reviewCard(for review: Review) -> some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            HStack {
                HStack(spacing: 2) {
                    Text(String(repeating: "★", count: review.rating))
                        .foregroundStyle(ZDTheme.accent)

                    Text(String(repeating: "☆", count: 5 - review.rating))
                        .foregroundStyle(ZDTheme.textSecondary)
                }

                Spacer()

                if let date = review.created_at {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(ZDTheme.textSecondary)
                }
            }

            if let comment = review.comment, !comment.isEmpty {
                Text(comment)
                    .zdBodyStyle()
            }
        }
        .zdSoftCard()
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

        return placeURLs + reviewURLs
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
