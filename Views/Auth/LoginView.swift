//
//  LoginView.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 25/02/2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: ZDTheme.spacingL) {
                    VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
                        Text("Welkom")
                            .zdTitleStyle()

                        Text("Log in of maak een account aan om reviews en foto's toe te voegen.")
                            .zdSecondaryStyle()
                    }

                    VStack(spacing: ZDTheme.spacingM) {
                        VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
                            Text("E-mailadres")
                                .zdHeadlineStyle()

                            TextField("naam@voorbeeld.nl", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .foregroundStyle(ZDTheme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: ZDTheme.spacingXS) {
                            Text("Wachtwoord")
                                .zdHeadlineStyle()

                            SecureField("Vul je wachtwoord in", text: $password)
                                .padding()
                                .background(Color.white.opacity(0.08))
                                .foregroundStyle(ZDTheme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous))
                        }

                        Button("Login") {
                            Task {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                        .buttonStyle(ZDPrimaryButtonStyle())

                        Button("Account aanmaken") {
                            Task {
                                await auth.signUp(email: email, password: password)
                            }
                        }
                        .buttonStyle(ZDAccentButtonStyle())
                    }
                    .zdCard()

                    if let error = auth.errorMessage {
                        Text(error)
                            .foregroundStyle(ZDTheme.error)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous))
                    }
                }
                .padding(ZDTheme.spacingM)
            }
            .navigationTitle("Account")
            .toolbarBackground(ZDTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .zdScreenBackground()
        }
    }
}
