//
//  RootView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var auth: AuthViewModel

    var body: some View {
        TabView {
            PlacesMapView()
                .tabItem {
                    Label("Kaart", systemImage: "map")
                }

            if auth.isAuthed {
                AccountView()
                    .tabItem {
                        Label("Account", systemImage: "person")
                    }
            } else {
                LoginView()
                    .tabItem {
                        Label("Login", systemImage: "person")
                    }
            }

            if auth.isAuthed && auth.isAdmin() {
                AdminDashboardView()
                    .tabItem {
                        Label("Admin", systemImage: "wrench.and.screwdriver")
                    }
            }
        }
        .tint(ZDTheme.accent)
    }
}
