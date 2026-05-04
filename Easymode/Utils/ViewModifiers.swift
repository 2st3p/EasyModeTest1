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

// MARK: - iOS Button Style
struct iOSButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color

    init(backgroundColor: Color = .primaryChartreuse, foregroundColor: Color = .softBlack) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sansMedium(18))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(999) // Full rounded
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct iOSCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
            )
            .paperShadow()
    }
}

extension View {
    func iosCard() -> some View {
        modifier(iOSCardModifier())
    }
}

