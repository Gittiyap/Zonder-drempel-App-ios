//
//  DesignSystem.swift
//  Zonder drempel App
//
//  Created by Lennart Mooijweer on 09/03/2026.
//

import SwiftUI

// MARK: - Theme

enum ZDTheme {
    // Brand colors
    static let background = Color(hex: "#1F355C")     // Donkerblauw
    static let primary = Color(hex: "#1A2782")        // Primair blauw
    static let accent = Color(hex: "#2DC2A9")         // Frisgroen
    static let secondary = Color(hex: "#C8EDF4")      // Lichtblauw

    // Text
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.78)
    static let textMuted = Color.white.opacity(0.58)
    static let textOnLight = Color(hex: "#1F355C")

    // Feedback
    static let success = Color(hex: "#2DC2A9")
    static let warning = Color.orange
    static let error = Color.red.opacity(0.92)

    // Surfaces
    static let surface = Color.white.opacity(0.08)
    static let surfaceSoft = Color.white.opacity(0.06)
    static let surfaceStrong = Color.white.opacity(0.12)
    static let border = Color.white.opacity(0.10)
    static let borderStrong = Color.white.opacity(0.16)

    // Layout
    static let cornerRadius: CGFloat = 14
    static let largeCornerRadius: CGFloat = 20

    static let spacingXS: CGFloat = 6
    static let spacingS: CGFloat = 10
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24

    static let cardOpacity: Double = 0.18
    static let subtleOpacity: Double = 0.10
}

// MARK: - Hex Color Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1
            g = 1
            b = 1
        }

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Button Styles

struct ZDPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ZDTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, ZDTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(ZDTheme.primary.opacity(configuration.isPressed ? 0.86 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ZDSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ZDTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, ZDTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.10 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ZDAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ZDTheme.textOnLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, ZDTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(ZDTheme.accent.opacity(configuration.isPressed ? 0.86 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Screen / Card Modifiers

struct ZDScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            ZDTheme.background.ignoresSafeArea()
            content
        }
    }
}

struct ZDCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ZDTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(ZDTheme.secondary.opacity(ZDTheme.cardOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(ZDTheme.border, lineWidth: 1)
            )
    }
}

struct ZDSoftCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ZDTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(ZDTheme.surfaceSoft)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}

// MARK: - Input Field Style

struct ZDInputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(ZDTheme.textPrimary)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .fill(ZDTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ZDTheme.cornerRadius, style: .continuous)
                    .stroke(ZDTheme.borderStrong, lineWidth: 1)
            )
    }
}

extension View {
    func zdScreenBackground() -> some View {
        modifier(ZDScreenBackground())
    }

    func zdCard() -> some View {
        modifier(ZDCardModifier())
    }

    func zdSoftCard() -> some View {
        modifier(ZDSoftCardModifier())
    }

    func zdInputField() -> some View {
        modifier(ZDInputFieldModifier())
    }
}

// MARK: - Badge

struct ZDBadge: View {
    let text: String
    let color: Color
    let foreground: Color

    init(
        text: String,
        color: Color = ZDTheme.accent,
        foreground: Color = ZDTheme.textOnLight
    ) {
        self.text = text
        self.color = color
        self.foreground = foreground
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.18))
            .foregroundStyle(foreground == ZDTheme.textOnLight ? color : foreground)
            .clipShape(Capsule())
    }
}

// MARK: - Label Row / Accessibility Row

struct ZDStatusRow: View {
    let title: String
    let isOn: Bool

    var body: some View {
        HStack(spacing: ZDTheme.spacingS) {
            Image(systemName: isOn ? "checkmark.seal.fill" : "xmark.seal")
                .foregroundStyle(isOn ? ZDTheme.accent : ZDTheme.textSecondary)

            Text(title)
                .foregroundStyle(ZDTheme.textPrimary)

            Spacer()
        }
        .font(.body)
    }
}

// MARK: - Section Container

struct ZDSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ZDTheme.spacingS) {
            Text(title)
                .zdHeadlineStyle()
            content
        }
        .zdCard()
    }
}

// MARK: - Marker Colors

enum ZDMapStyle {
    static let poiMarker = Color.blue
    static let accessibleMarker = ZDTheme.accent
}

// MARK: - Typography Helpers

extension Text {
    func zdTitleStyle() -> some View {
        self
            .font(.title2.weight(.bold))
            .foregroundStyle(ZDTheme.textPrimary)
    }

    func zdHeadlineStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(ZDTheme.textPrimary)
    }

    func zdBodyStyle() -> some View {
        self
            .font(.body)
            .foregroundStyle(ZDTheme.textPrimary)
    }

    func zdSecondaryStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundStyle(ZDTheme.textSecondary)
    }

    func zdMutedStyle() -> some View {
        self
            .font(.footnote)
            .foregroundStyle(ZDTheme.textMuted)
    }
}
