//
//  AddReviewView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//

import SwiftUI
import PhotosUI

struct AddReviewView: View {
    let placeId: UUID
    let userId: UUID
    let onSubmit: (Int, String?, [Data]) async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var imageDatas: [Data] = []
    @State private var isLoadingImages = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZDTheme.spacingL) {
                    Text("Review toevoegen")
                        .zdTitleStyle()

                    ratingSection
                    commentSection
                    photoSection
                }
                .padding(ZDTheme.spacingM)
            }
            .background(ZDTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task(id: selectedItems) {
                await loadImages(from: selectedItems)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                    .foregroundStyle(ZDTheme.textPrimary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "Opslaan..." : "Plaats") {
                        Task {
                            isSubmitting = true
                            await onSubmit(
                                rating,
                                comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment,
                                imageDatas
                            )
                            isSubmitting = false
                            dismiss()
                        }
                    }
                    .foregroundStyle(ZDTheme.accent)
                    .disabled(isSubmitting || isLoadingImages)
                }
            }
        }
    }

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text("Rating")
                .zdHeadlineStyle()

            Picker("Rating", selection: $rating) {
                ForEach(1...5, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.segmented)
            .tint(ZDTheme.accent)
            .padding(12)
            .background(
                RoundedRectangle(
                    cornerRadius: ZDTheme.cornerRadius,
                    style: .continuous
                )
                .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: ZDTheme.cornerRadius,
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .zdCard()
    }

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text("Toelichting")
                .zdHeadlineStyle()

            ZStack(alignment: .topLeading) {
                if comment.isEmpty {
                    Text("Korte ervaring...")
                        .foregroundStyle(ZDTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $comment)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(ZDTheme.textPrimary)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color.clear)
            }
            .background(
                RoundedRectangle(
                    cornerRadius: ZDTheme.cornerRadius,
                    style: .continuous
                )
                .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: ZDTheme.cornerRadius,
                    style: .continuous
                )
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .zdCard()
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text("Foto's (optioneel)")
                .zdHeadlineStyle()

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 3,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Foto toevoegen")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(ZDSecondaryButtonStyle())

            if isLoadingImages {
                HStack(spacing: ZDTheme.spacingS) {
                    ProgressView()
                        .tint(ZDTheme.accent)

                    Text("Foto's laden...")
                        .foregroundStyle(ZDTheme.textSecondary)
                        .font(.footnote)
                }
            } else {
                Text("Geselecteerde foto's: \(imageDatas.count)")
                    .foregroundStyle(ZDTheme.textSecondary)
                    .font(.footnote)
            }
        }
        .zdCard()
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        isLoadingImages = true
        imageDatas.removeAll()

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                imageDatas.append(data)
            }
        }

        isLoadingImages = false
    }
}
