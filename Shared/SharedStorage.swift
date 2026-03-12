//
//  SharedStorage.swift
//  EasyModeTest1
//
//  Shared storage utilities for communication between the main app and extensions.
//  Uses App Groups to share data across processes.
//
//  Add this file to all targets: Main App, DeviceActivityMonitorExtension,
//  ShieldConfigurationExtension, ShieldActionExtension
//

import Foundation
#if canImport(FamilyControls)
import FamilyControls
#endif

enum ShieldContentContext {
    case application
    case category
    case webDomain
}

struct ShieldContentConfiguration: Equatable {
    let title: String
    let subtitle: String
    let primaryButtonLabel: String
}

enum ShieldContentBuilder {
    private static let fallbackTitle = "Stay focused"
    private static let fallbackSubtitle = "That can wait... get your shit done first."
    private static let primaryButtonLabel = "Back to focus"

    static func build(
        currentTask: String?,
        blockedAppName: String?,
        context: ShieldContentContext
    ) -> ShieldContentConfiguration {
        let normalizedTask = normalized(currentTask)
        let normalizedAppName = normalized(blockedAppName)

        let subtitle: String
        switch context {
        case .application:
            if let appName = normalizedAppName {
                subtitle = "\(appName) can wait... get your shit done first."
            } else {
                subtitle = fallbackSubtitle
            }
        case .category, .webDomain:
            subtitle = fallbackSubtitle
        }

        return ShieldContentConfiguration(
            title: normalizedTask ?? fallbackTitle,
            subtitle: subtitle,
            primaryButtonLabel: primaryButtonLabel
        )
    }

    private static func normalized(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}

/// Keys for shared UserDefaults storage
enum SharedStorageKey: String {
    /// The user's app selection for blocking
    case appSelection = "EasyMode.SelectedApps"
    
    /// The current task text being focused on
    case currentTask = "EasyMode.CurrentTask"
    
    /// Whether a focus session is currently active
    case isFocusActive = "EasyMode.IsFocusActive"
    
    /// Timestamp when the current focus session started
    case focusStartTime = "EasyMode.FocusStartTime"
}

/// Provides shared storage access across app and extensions
final class SharedStorage {
    
    // MARK: - Configuration
    
    /// App Group identifier - update with your actual identifier
    /// Must match the App Group configured in Xcode for all targets
    static let appGroupIdentifier = "group.com.easymode.shared"
    
    // MARK: - Shared Instance
    
    static let shared = SharedStorage(defaults: SharedStorage.makeDefaults())
    
    // MARK: - Properties
    
    /// UserDefaults for the App Group
    private let defaults: UserDefaults
    
    // MARK: - Initialization
    
    private static func makeDefaults() -> UserDefaults {
        if let groupDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) {
            return groupDefaults
        }
        print("⚠️ App Group '\(Self.appGroupIdentifier)' not available. Using standard UserDefaults.")
        return .standard
    }

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    // MARK: - Current Task
    
    /// Saves the current task text
    func setCurrentTask(_ taskText: String) {
        defaults.set(taskText, forKey: SharedStorageKey.currentTask.rawValue)
    }
    
    /// Retrieves the current task text
    func getCurrentTask() -> String? {
        return defaults.string(forKey: SharedStorageKey.currentTask.rawValue)
    }
    
    /// Clears the current task
    func clearCurrentTask() {
        defaults.removeObject(forKey: SharedStorageKey.currentTask.rawValue)
    }
    
    // MARK: - Focus Session State
    
    /// Sets whether a focus session is active
    func setFocusActive(_ isActive: Bool, startTime: Date? = nil) {
        defaults.set(isActive, forKey: SharedStorageKey.isFocusActive.rawValue)
        
        if isActive {
            defaults.set(startTime ?? Date(), forKey: SharedStorageKey.focusStartTime.rawValue)
        } else {
            defaults.removeObject(forKey: SharedStorageKey.focusStartTime.rawValue)
        }
    }
    
    /// Returns whether a focus session is currently active
    func isFocusActive() -> Bool {
        return defaults.bool(forKey: SharedStorageKey.isFocusActive.rawValue)
    }
    
    /// Returns when the current focus session started
    func getFocusStartTime() -> Date? {
        return defaults.object(forKey: SharedStorageKey.focusStartTime.rawValue) as? Date
    }
    
    // MARK: - App Selection
    
    #if canImport(FamilyControls)
    /// Saves the app selection for blocking
    func saveSelection(_ selection: FamilyActivitySelection) {
        do {
            let data = try PropertyListEncoder().encode(selection)
            defaults.set(data, forKey: SharedStorageKey.appSelection.rawValue)
        } catch {
            print("⚠️ Failed to save app selection: \(error)")
        }
    }
    
    /// Loads the saved app selection
    func loadSelection() -> FamilyActivitySelection? {
        guard let data = defaults.data(forKey: SharedStorageKey.appSelection.rawValue) else {
            return nil
        }
        
        do {
            return try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("⚠️ Failed to load app selection: \(error)")
            return nil
        }
    }
    #endif
    
    // MARK: - Utilities
    
    /// Clears all shared storage (for debugging/reset)
    func clearAll() {
        for key in SharedStorageKey.allCases {
            defaults.removeObject(forKey: key.rawValue)
        }
    }
}

// MARK: - CaseIterable for Keys

extension SharedStorageKey: CaseIterable {}

