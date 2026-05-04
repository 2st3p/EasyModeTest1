import Foundation
import Testing

struct ExtensionConfigurationTests {

    // MARK: - Bundle Access

    private func extensionBundle(named name: String) throws -> Bundle {
        let plugInsURL = try #require(Bundle.main.builtInPlugInsURL)
        let bundleURL = try #require(
            plugInsURL.appendingPathComponent("\(name).appex"),
            "Missing embedded extension: \(name).appex"
        )
        return try #require(Bundle(url: bundleURL), "Failed to load bundle at \(bundleURL)")
    }

    private func extensionInfo(_ name: String) throws -> [String: Any] {
        let bundle = try extensionBundle(named: name)
        return try #require(bundle.infoDictionary, "\(name) has no Info.plist")
    }

    private func nsExtension(_ name: String) throws -> [String: Any] {
        let info = try extensionInfo(name)
        return try #require(info["NSExtension"] as? [String: Any], "\(name) missing NSExtension dict")
    }

    // MARK: - Extension Point Identifiers

    @Test
    func shieldConfigurationExtension_pointIdentifier() throws {
        let ext = try nsExtension("ShieldConfigurationExtension")
        let pointID = try #require(ext["NSExtensionPointIdentifier"] as? String)

        #expect(pointID == "com.apple.ManagedSettingsUI.shield-configuration-service")
    }

    @Test
    func shieldActionExtension_pointIdentifier() throws {
        let ext = try nsExtension("ShieldActionExtension")
        let pointID = try #require(ext["NSExtensionPointIdentifier"] as? String)

        #expect(pointID == "com.apple.ManagedSettings.shield-action-service")
    }

    @Test
    func deviceActivityMonitorExtension_pointIdentifier() throws {
        let ext = try nsExtension("DeviceActivityMonitorExtension")
        let pointID = try #require(ext["NSExtensionPointIdentifier"] as? String)

        #expect(pointID == "com.apple.deviceactivity.monitor")
    }

    // MARK: - Principal Classes

    @Test
    func shieldConfigurationExtension_principalClass() throws {
        let ext = try nsExtension("ShieldConfigurationExtension")
        let principal = try #require(ext["NSExtensionPrincipalClass"] as? String)

        #expect(principal == "ShieldConfigurationExtension.ShieldConfigurationExtension")
    }

    @Test
    func shieldActionExtension_principalClass() throws {
        let ext = try nsExtension("ShieldActionExtension")
        let principal = try #require(ext["NSExtensionPrincipalClass"] as? String)

        #expect(principal == "ShieldActionExtension.ShieldActionExtension")
    }

    @Test
    func deviceActivityMonitorExtension_principalClass() throws {
        let ext = try nsExtension("DeviceActivityMonitorExtension")
        let principal = try #require(ext["NSExtensionPrincipalClass"] as? String)

        #expect(principal == "DeviceActivityMonitorExtension.DeviceActivityMonitorExtension")
    }

    // MARK: - All Expected Extensions Are Embedded

    @Test
    func allExpectedExtensionsAreEmbedded() throws {
        let plugInsURL = try #require(Bundle.main.builtInPlugInsURL)
        let expectedExtensions = [
            "ShieldConfigurationExtension",
            "ShieldActionExtension",
            "DeviceActivityMonitorExtension"
        ]

        for name in expectedExtensions {
            let url = plugInsURL.appendingPathComponent("\(name).appex")
            #expect(
                FileManager.default.fileExists(atPath: url.path),
                "\(name).appex is not embedded in the app bundle"
            )
        }
    }

    // MARK: - App Group Consistency (via Info.plist bundle ID)

    @Test
    func allExtensions_shareSameTeamPrefix() throws {
        let extensions = [
            "ShieldConfigurationExtension",
            "ShieldActionExtension",
            "DeviceActivityMonitorExtension"
        ]

        var bundleIDs: [String: String] = [:]
        for name in extensions {
            let info = try extensionInfo(name)
            let id = try #require(info["CFBundleIdentifier"] as? String)
            bundleIDs[name] = id
        }

        let expectedPrefix = "name.erikkernan.easymode."
        for (name, id) in bundleIDs {
            #expect(
                id.hasPrefix(expectedPrefix),
                "\(name) bundle ID '\(id)' does not start with expected prefix"
            )
        }
    }
}
