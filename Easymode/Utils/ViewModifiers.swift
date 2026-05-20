//
//  ViewModifiers.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

// MARK: - Background Modifiers
struct ParchmentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.parchment)
    }
}

extension View {
    func parchmentBackground() -> some View {
        modifier(ParchmentBackgroundModifier())
    }
}

// MARK: - Shadow Modifiers
struct PaperShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct PaperShadowLargeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
    }
}

extension View {
    func paperShadow() -> some View {
        modifier(PaperShadowModifier())
    }

    func paperShadowLarge() -> some View {
        modifier(PaperShadowLargeModifier())
    }
}
