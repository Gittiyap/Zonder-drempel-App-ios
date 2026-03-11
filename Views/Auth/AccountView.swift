//
//  AccountView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI
import PhotosUI

import SwiftUI
import PhotosUI

@MainActor
struct AccountView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @StateObject private var vm = AccountViewModel()

    @State private var selectedAvatarItem: PhotosPickerItem?
    @State private var selectedPlace: Place?

    private let profileRepo = UserProfileRepository()

    var body: some View {
        let isUploadingAvatar = vm.isUploadingAvatar

        return NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZDTheme.spacingL) {
                    profileSection(isUploadingAvatar: isUploadingAvatar)
                    myReviewsSection
                    favoritesSection
                    savedSection
                    logoutSection
                }
                .padding(ZDTheme.spacingM)
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await loadAccountData()
            }
            .task(id: selectedAvatarItem) {
                await handleAvatarSelection()
            }
            .overlay(alignment: .top) {
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(ZDTheme.textPrimary)
                        .padding()
                        .background(Color.red.opacity(0.18))
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ZDTheme.cornerRadius,
                                style: .continuous
                            )
                        )
                        .padding()
                }
            }
            .sheet(item: $selectedPlace) { place in
                PlaceDetailView(place: place)
            }
            .zdScreenBackground()
        }
    }
    private func profileSection(isUploadingAvatar: Bool) -> some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingM) {
            HStack(spacing: ZDTheme.spacingM) {
                avatarView

                VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
                    Text(auth.userEmail ?? "Geen e-mailadres")
                        .zdHeadlineStyle()

                    Text("Persoonlijk account")
                        .zdSecondaryStyle()
                }

                Spacer()
            }

            PhotosPicker(
                selection: $selectedAvatarItem,
                matching: .images
            ) {
                HStack {
                    if isUploadingAvatar {
                        ProgressView()
                            .tint(ZDTheme.accent)
                    }

                    Label("Profielfoto toevoegen", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(ZDSecondaryButtonStyle())
        }
        .zdCard()
    }

    private var avatarView: some View {
        Group {
            if let path = vm.profile?.avatar_path,
               let url = try? profileRepo.publicURL(for: path) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(ZDTheme.accent)

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        fallbackAvatar

                    @unknown default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var fallbackAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.08))

            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundStyle(ZDTheme.textSecondary)
        }
    }

    private var myReviewsSection: some View {
        ZDSection("Mijn reviews") {
            if vm.myReviews.isEmpty {
                Text("Je hebt nog geen reviews geplaatst.")
                    .zdSecondaryStyle()
            } else {
                ForEach(vm.myReviews) { review in
                    VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
                        HStack {
                            Text(String(repeating: "★", count: review.rating))
                                .foregroundStyle(ZDTheme.accent)

                            Text(String(repeating: "☆", count: 5 - review.rating))
                                .foregroundStyle(ZDTheme.textSecondary)

                            Spacer()
                        }

                        if let comment = review.comment, !comment.isEmpty {
                            Text(comment)
                                .zdBodyStyle()
                        }
                    }
                    .zdSoftCard()
                }
            }
        }
    }

    private var favoritesSection: some View {
        ZDSection("Favoriete locaties") {
            if vm.favoritePlaces.isEmpty {
                Text("Je hebt nog geen favoriete locaties.")
                    .zdSecondaryStyle()
            } else {
                VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
                    Text("Aantal favorieten: \(vm.favoritePlaces.count)")
                        .zdBodyStyle()

                    ForEach(vm.favoritePlaces) { place in
                        placeRow(place: place, systemImage: "heart.fill")
                    }
                }
            }
        }
    }

    private var savedSection: some View {
        ZDSection("Opgeslagen locaties") {
            if vm.savedPlaces.isEmpty {
                Text("Je hebt nog geen opgeslagen locaties.")
                    .zdSecondaryStyle()
            } else {
                VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
                    Text("Aantal opgeslagen locaties: \(vm.savedPlaces.count)")
                        .zdBodyStyle()

                    ForEach(vm.savedPlaces) { place in
                        placeRow(place: place, systemImage: "bookmark.fill")
                    }
                }
            }
        }
    }

    private func placeRow(place: Place, systemImage: String) -> some View {
        Button {
            selectedPlace = place
        } label: {
            HStack(alignment: .top, spacing: ZDTheme.spacingM) {
                Image(systemName: systemImage)
                    .foregroundStyle(ZDTheme.accent)
                    .font(.headline)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
                    Text(place.name)
                        .zdBodyStyle()

                    Text(place.address)
                        .zdSecondaryStyle()

                    Text(place.type.capitalized)
                        .font(.caption)
                        .foregroundStyle(ZDTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(ZDTheme.textSecondary)
            }
            .padding(ZDTheme.spacingM)
            .background(Color.white.opacity(0.04))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ZDTheme.cornerRadius,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    private var logoutSection: some View {
        Button("Uitloggen", role: .destructive) {
            Task {
                await auth.signOut()
            }
        }
        .buttonStyle(ZDSecondaryButtonStyle())
    }

    private func loadAccountData() async {
        guard let uid = auth.userId else { return }

        await vm.load(userId: uid)
        await vm.loadMyReviews(userId: uid)
    }

    private func handleAvatarSelection() async {
        guard let uid = auth.userId,
              let item = selectedAvatarItem,
              let data = try? await item.loadTransferable(type: Data.self) else {
            return
        }

        await vm.uploadAvatar(
            userId: uid,
            email: auth.userEmail,
            imageData: data
        )
    }
}
