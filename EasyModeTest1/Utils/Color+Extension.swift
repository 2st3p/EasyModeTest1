//
//  Color+Extension.swift
//  EasyModeTest1
//
//  Brand and semantic colors used throughout the main app.
//  Brand tokens are defined canonically in `Shared/BrandTokens.swift`
//  and the extensions/widget keep local mirrors that must stay in sync.
//

import SwiftUI
import UIKit

extension Color {
    // MARK: - Brand surfaces (canonical: Shared/BrandTokens.swift)

    /// Warm paper background. Light-mode parchment; reads slightly lifted vs dark walnut in dark mode.
    static let parchment = Color("ParchmentBackground", bundle: .main, fallback: .brandParchment)

    /// Primary text. Dark on parchment in light mode; warm bone in dark mode.
    static let softBlack = Color("SoftBlackForeground", bundle: .main, fallback: .brandSoftBlack)

    // MARK: - Brand accents

    static let primaryChartreuse = Color.brandChartreuse
    static let secondaryPink = Color.brandPink

    // MARK: - Semantic colors

    /// Card / elevated surface. Pure white in light mode, slightly lifted in dark mode.
    static let cardBackground = Color("CardBackground", bundle: .main, fallback: .white)

    /// Secondary text — passes WCAG AA on parchment.
    /// `#6B6B6B` in light; warm dim bone in dark.
    static let mutedForeground = Color(
        "MutedForeground",
        bundle: .main,
        fallback: Color(red: 0.42, green: 0.42, blue: 0.42)
    )

    /// Filled but un-emphasized background (e.g. category chips).
    static let mutedBackground = Color(
        "MutedBackground",
        bundle: .main,
        fallback: Color(red: 0.941, green: 0.941, blue: 0.941)
    )

    /// Hairline borders and dividers.
    static let borderColor = Color(
        "BorderColor",
        bundle: .main,
        fallback: Color(red: 0.9, green: 0.9, blue: 0.9)
    )

    /// Destructive accent — `#EB4343`.
    static let destructive = Color(red: 0.922, green: 0.263, blue: 0.263)

    /// System-style success green — `#34C759`. Used for completion glyphs and confirmations.
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)

    /// Subdued placeholder for empty text fields. Adapts in dark mode.
    static let placeholderForeground = Color(.placeholderText)
}

// MARK: - Asset-or-fallback helper

private extension Color {
    /// Initializes a color from an asset catalog name, falling back to the supplied color when
    /// the asset isn't present. Lets us roll out the asset catalog colors incrementally without
    /// crashing if a developer forgets to add the asset.
    init(_ name: String, bundle: Bundle?, fallback: Color) {
        #if canImport(UIKit)
        if let resolved = UIColor(named: name, in: bundle, compatibleWith: nil) {
            self = Color(uiColor: resolved)
            return
        }
        #endif
        self = fallback
    }
}
