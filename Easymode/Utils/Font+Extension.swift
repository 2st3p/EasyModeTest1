//
//  Font+Extension.swift
//  Easymode
//
//  Dynamic-Type-aware typography. Numeric sizes in legacy APIs map to the nearest
//  semantic `Font.TextStyle` so hierarchy scales with accessibility settings.
//

import SwiftUI

extension Font {
    // MARK: - Serif (display)

    /// Hero headings (~largeTitle at default Dynamic Type).
    static func serifTitle(_ size: CGFloat = 36) -> Font {
        switch size {
        case ..<24:
            return .system(.title3, design: .serif).weight(.medium)
        case ..<30:
            return .system(.title2, design: .serif).weight(.medium)
        case ..<34:
            return .system(.title, design: .serif).weight(.medium)
        default:
            return .system(.largeTitle, design: .serif).weight(.medium)
        }
    }

    /// Secondary serif headline (merged with `serifTitle` ladder — keeps call sites readable).
    static func serifLarge(_ size: CGFloat = 32) -> Font {
        serifTitle(size)
    }

    /// Pull quotes and supporting serif body.
    static func serifBody(_ size: CGFloat = 16) -> Font {
        switch size {
        case ..<17:
            return .system(.callout, design: .serif).weight(.regular)
        default:
            return .system(.title3, design: .serif).weight(.regular)
        }
    }

    // MARK: - Sans (UI)

    static func sansBody(_ size: CGFloat = 16) -> Font {
        switch size {
        case ..<15:
            return .system(.subheadline, design: .default).weight(.regular)
        default:
            return .system(.body, design: .default).weight(.regular)
        }
    }

    static func sansMedium(_ size: CGFloat = 16) -> Font {
        switch size {
        case ..<15:
            return .system(.subheadline, design: .default).weight(.medium)
        case ..<19:
            return .system(.body, design: .default).weight(.medium)
        default:
            return .system(.title3, design: .default).weight(.medium)
        }
    }

    /// Captions and micro-labels (covers former 12pt / 14pt gaps).
    static func sansSmall(_ size: CGFloat = 12) -> Font {
        switch size {
        case ..<13:
            return .system(.caption2, design: .default).weight(.regular)
        case ..<15:
            return .system(.caption, design: .default).weight(.regular)
        default:
            return .system(.subheadline, design: .default).weight(.regular)
        }
    }

    static func sansTiny(_ size: CGFloat = 10) -> Font {
        switch size {
        case ..<11:
            return .system(.caption2, design: .default).weight(.medium)
        default:
            return .system(.caption, design: .default).weight(.medium)
        }
    }
}
