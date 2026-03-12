//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Handles user interactions with the shield view buttons.
//  Determines what happens when users tap the primary/secondary buttons.
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Shield Action Extension"
//  3. Name it "ShieldActionExtension"
//  4. Add this file to the new target
//  5. Enable "App Groups" capability and add "group.com.easymode.shared"
//

import ManagedSettings
import ManagedSettingsUI

/// Extension that handles shield button actions.
/// Controls what happens when users interact with blocked app shields.
class ShieldActionExtension: ShieldActionDelegate {
    
    // MARK: - Application Shield Actions
    
    /// Handles the primary button action for a blocked application
    override func handle(action: ShieldAction, for application: Application, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Primary button dismisses the shield (user goes back to home)
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // No secondary button configured, but handle defensively
            completionHandler(.close)
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Web Domain Shield Actions
    
    /// Handles the primary button action for a blocked web domain
    override func handle(action: ShieldAction, for webDomain: WebDomain, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            completionHandler(.close)
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Category Shield Actions
    
    /// Handles the primary button action for a blocked category
    override func handle(action: ShieldAction, for category: ActivityCategory, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            completionHandler(.close)
            
        @unknown default:
            completionHandler(.close)
        }
    }
}

// MARK: - Future Enhancement Notes
/*
 For future "Strict Mode" implementation, you could:
 
 1. Add a "defer" response that keeps the shield but allows a brief delay:
    completionHandler(.defer)
 
 2. Read configuration from App Group UserDefaults to determine behavior:
    - If strict mode is enabled: always .close
    - If soft mode is enabled: allow .defer with a timer
 
 3. Track "break attempts" for analytics:
    - Log each time user hits the shield
    - Could feed into a "willpower score" or similar feature
 */




