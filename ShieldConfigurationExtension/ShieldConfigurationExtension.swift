//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Customizes the appearance of the shield view shown when a user
//  attempts to open a blocked app during a focus session.
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Shield Configuration Extension"
//  3. Name it "ShieldConfigurationExtension"
//  4. Add this file to the new target
//  5. Enable "App Groups" capability and add "group.com.easymode.shared"
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Extension that provides custom shield configuration for blocked apps.
/// The shield is displayed when a user tries to open a blocked app.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // MARK: - Shield Configuration

    /// Provides the shield configuration for a blocked application
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createShieldConfiguration(
            for: .application,
            blockedAppName: application.localizedDisplayName
        )
    }

    /// Provides the shield configuration for a blocked application in a category
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(
            for: .application,
            blockedAppName: application.localizedDisplayName
        )
    }

    /// Provides the shield configuration for a blocked web domain
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createShieldConfiguration(for: .webDomain)
    }

    /// Provides the shield configuration for a web domain in a category
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createShieldConfiguration(for: .webDomain)
    }

    // MARK: - Configuration Builder

    /// Creates the shield configuration with EasyMode branding
    private func createShieldConfiguration(
        for context: ShieldContentContext,
        blockedAppName: String? = nil
    ) -> ShieldConfiguration {
        let content = ShieldContentBuilder.build(
            currentTask: getCurrentTask(),
            blockedAppName: blockedAppName,
            context: context
        )

        // EasyMode brand colors (matching the app's parchment/warm theme)
        let backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0) // Warm parchment
        let primaryColor = UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)    // Soft black
        let secondaryColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)  // Muted gray

        return ShieldConfiguration(
            backgroundBlurStyle: .light,
            backgroundColor: backgroundColor,
            icon: nil, // Uses app icon by default
            title: ShieldConfiguration.Label(
                text: content.title,
                color: primaryColor
            ),
            subtitle: ShieldConfiguration.Label(
                text: content.subtitle,
                color: secondaryColor
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: content.primaryButtonLabel,
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.541, green: 0.788, blue: 0.149, alpha: 1.0), // Chartreuse #8AC926
            secondaryButtonLabel: nil // No secondary button - strict blocking
        )
    }
    
    /// Retrieves the current task text from shared UserDefaults
    private func getCurrentTask() -> String? {
        SharedStorage.shared.getCurrentTask()
    }
}
