//
//  HapticManager.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import UIKit

/// Manages haptic feedback for different interaction types
final class HapticManager {
    static let shared = HapticManager()
    
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for immediate use
        selectionGenerator.prepare()
        impactGenerator.prepare()
        heavyImpactGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    /// Light haptic for selection/typing
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    /// Medium impact for button presses
    func impact() {
        impactGenerator.impactOccurred()
        impactGenerator.prepare()
    }
    
    /// Heavy impact for significant actions
    func heavyImpact() {
        heavyImpactGenerator.impactOccurred()
        heavyImpactGenerator.prepare()
    }
    
    /// Success notification for task completion
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
    
    /// Error notification
    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
}

