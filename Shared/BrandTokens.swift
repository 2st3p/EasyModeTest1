//
//  BrandTokens.swift
//  EasyModeTest1
//
//  SwiftUI color helpers for the main app target. RGB tuples are defined in
//  `Shared/BrandRGB.swift` and compiled into extensions as well.
//

import SwiftUI

/// SwiftUI helpers that wrap `BrandRGB` for the main app module.
enum BrandTokens {
    static let parchmentRGB = BrandRGB.parchment
    static let softBlackRGB = BrandRGB.softBlack
    static let chartreuseRGB = BrandRGB.chartreuse
    static let pinkRGB = BrandRGB.pink
}

extension Color {
    static let brandParchment = Color(
        red: BrandRGB.parchment.red,
        green: BrandRGB.parchment.green,
        blue: BrandRGB.parchment.blue
    )

    static let brandSoftBlack = Color(
        red: BrandRGB.softBlack.red,
        green: BrandRGB.softBlack.green,
        blue: BrandRGB.softBlack.blue
    )

    static let brandChartreuse = Color(
        red: BrandRGB.chartreuse.red,
        green: BrandRGB.chartreuse.green,
        blue: BrandRGB.chartreuse.blue
    )

    static let brandPink = Color(
        red: BrandRGB.pink.red,
        green: BrandRGB.pink.green,
        blue: BrandRGB.pink.blue
    )
}
