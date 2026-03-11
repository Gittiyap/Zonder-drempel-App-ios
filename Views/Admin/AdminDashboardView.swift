//
//  Untitled.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI

struct AdminDashboardView: View {
    @State private var showingNew = false
    @StateObject private var vm = PlacesViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.places.isEmpty {
                    VStack(spacing: ZDTheme.spacingM) {
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 48))
                            .foregroundStyle(ZDTheme.accent)

                        Text("Nog geen locaties")
                            .zdHeadlineStyle()

                        Text("Voeg een nieuwe Zonder Drempels-locatie toe om te starten.")
                            .zdSecondaryStyle()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: ZDTheme.spacingM) {
                            ForEach(vm.places) { place in
                                NavigationLink {
                                    PlaceEditorView(mode: .edit(place))
                                } label: {
                                    VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
                                        Text(place.name)
                                            .zdHeadlineStyle()

                                        Text(place.address)
                                            .zdSecondaryStyle()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .zdCard()
                                }
                            }
                        }
                        .padding(ZDTheme.spacingM)
                    }
                }
            }
            .navigationTitle("Admin locaties")
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(ZDTheme.accent)
                    }
                }
            }
            .task { await vm.load() }
            .sheet(isPresented: $showingNew) {
                PlaceEditorView(mode: .new)
                    .presentationBackground(ZDTheme.background)
            }
            .zdScreenBackground()
        }
    }
}
