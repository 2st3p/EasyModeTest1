//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Customizes the appearance of the shield view shown when a user
//  attempts to open a blocked app during a focus session.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// MARK: - Brand colors (canonical: Shared/BrandRGB.swift)

private enum ShieldBrand {
    private static func uiColor(_ rgb: (red: Double, green: Double, blue: Double)) -> UIColor {
        UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
    }

    static let chartreuse = uiColor(BrandRGB.chartreuse)
    static let parchment = uiColor(BrandRGB.parchment)
    static let softBlack = uiColor(BrandRGB.softBlack)
    static let mutedForeground = uiColor(BrandRGB.mutedForeground)

    /// Matches the Live Activity / marketing mark (`circle.hexagongrid.fill`).
    static let shieldBrandIcon: UIImage = {
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .semibold)
        let raw = UIImage(systemName: "circle.hexagongrid.fill", withConfiguration: cfg) ?? UIImage()
        return raw.withTintColor(chartreuse, renderingMode: .alwaysOriginal)
    }()
}

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

        return ShieldConfiguration(
            backgroundBlurStyle: .light,
            backgroundColor: ShieldBrand.parchment,
            icon: ShieldBrand.shieldBrandIcon,
            title: ShieldConfiguration.Label(
                text: content.title,
                color: ShieldBrand.softBlack
            ),
            subtitle: ShieldConfiguration.Label(
                text: content.subtitle,
                color: ShieldBrand.mutedForeground
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: content.primaryButtonLabel,
                color: .white
            ),
            primaryButtonBackgroundColor: ShieldBrand.chartreuse,
            secondaryButtonLabel: nil
        )
    }
    
    /// Retrieves the current task text from shared UserDefaults
    private func getCurrentTask() -> String? {
        SharedStorage.shared.getCurrentTask()
    }
}
