//
//  BrandRGB.swift
//  EasyMode
//
//  Foundation-only canonical brand RGB tuples. Compiled into the main app,
//  Family Controls extensions, and the Live Activity widget so targets never
//  duplicate literals. SwiftUI/UIKit wrappers live in BrandTokens or call sites.
//

import Foundation

/// Canonical sRGB components (0…1) for brand colors.
public enum BrandRGB {
    /// Hex `#FBF9F5` — warm paper background.
    public static let parchment: (red: Double, green: Double, blue: Double) =
        (0.984, 0.976, 0.961)

    /// Hex `#262626` — primary on-light text.
    public static let softBlack: (red: Double, green: Double, blue: Double) =
        (0.149, 0.149, 0.149)

    /// Hex `#8AC926` — chartreuse accent.
    public static let chartreuse: (red: Double, green: Double, blue: Double) =
        (0.541, 0.788, 0.149)

    /// Hex `#EB8698` — secondary pink accent.
    public static let pink: (red: Double, green: Double, blue: Double) =
        (235.0 / 255, 134.0 / 255, 152.0 / 255)

    /// Hex `#6B6B6B` — secondary / muted foreground (WCAG on parchment).
    public static let mutedForeground: (red: Double, green: Double, blue: Double) =
        (0.42, 0.42, 0.42)

    /// Semantic green for blocking-active chrome on Live Activity / shields.
    public static let blockingGreen: (red: Double, green: Double, blue: Double) =
        (0.1, green: 0.5, blue: 0.2)
}
