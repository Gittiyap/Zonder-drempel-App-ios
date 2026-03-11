//
//  PlacesMapView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 05/03/2026.
//
import SwiftUI
import MapKit

private enum MapSelection: Hashable, Identifiable {
    case place(UUID)
    case poi(UUID)

    var id: UUID {
        switch self {
        case .place(let id): return id
        case .poi(let id): return id
        }
    }
}

struct PlacesMapView: View {
    @StateObject private var vm = MapDataViewModel()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5719, longitude: 4.7683),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    @State private var selection: MapSelection? = nil

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $selection) {
                placesLayer
                poisLayer
            }
            .ignoresSafeArea()
            .navigationTitle("Zonder Drempels")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await vm.load()
            }
            .overlay(alignment: .top) {
                if let msg = vm.errorMessage {
                    Text(msg)
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
            .sheet(item: $selection) { sel in
                sheetContent(for: sel)
            }
        }
    }

    @MapContentBuilder
    private var placesLayer: some MapContent {
        ForEach(vm.places) { place in
            Marker(
                place.name,
                systemImage: "figure.roll",
                coordinate: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )
            )
            .tint(ZDMapStyle.accessibleMarker)
            .tag(MapSelection.place(place.id))
        }
    }

    @MapContentBuilder
    private var poisLayer: some MapContent {
        ForEach(vm.pois) { poi in
            Marker(
                poi.name,
                systemImage: "mappin.and.ellipse",
                coordinate: CLLocationCoordinate2D(
                    latitude: poi.latitude,
                    longitude: poi.longitude
                )
            )
            .tint(ZDMapStyle.poiMarker)
            .tag(MapSelection.poi(poi.id))
        }
    }

    @ViewBuilder
    private func sheetContent(for sel: MapSelection) -> some View {
        switch sel {
        case .place(let id):
            if let place = vm.places.first(where: { $0.id == id }) {
                NavigationStack {
                    PlaceBottomSheetView(place: place)
                        .presentationDetents([.fraction(0.34), .medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(ZDTheme.background)
                }
            } else {
                Text("Locatie niet gevonden.")
                    .padding()
            }

        case .poi(let id):
            if let poi = vm.pois.first(where: { $0.id == id }) {
                NavigationStack {
                    POIBottomSheetView(poi: poi)
                        .presentationDetents([.fraction(0.25), .medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(ZDTheme.background)
                }
            } else {
                Text("POI niet gevonden.")
                    .padding()
            }
        }
    }
}
