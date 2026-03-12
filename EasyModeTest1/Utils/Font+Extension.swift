//
//  Font+Extension.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

extension Font {
    // Serif font for headings and emphasis (matching Source Serif 4 from web)
    static func serifTitle(_ size: CGFloat = 36) -> Font {
        .system(size: size, design: .serif).weight(.medium)
    }
    
    static func serifLarge(_ size: CGFloat = 32) -> Font {
        .system(size: size, design: .serif).weight(.medium)
    }
    
    static func serifBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, design: .serif).weight(.regular)
    }
    
    // Sans font for UI elements (matching Inter from web)
    static func sansBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, design: .default).weight(.regular)
    }
    
    static func sansMedium(_ size: CGFloat = 16) -> Font {
        .system(size: size, design: .default).weight(.medium)
    }
    
    static func sansSmall(_ size: CGFloat = 12) -> Font {
        .system(size: size, design: .default).weight(.regular)
    }
    
    static func sansTiny(_ size: CGFloat = 10) -> Font {
        .system(size: size, design: .default).weight(.medium)
    }
}

