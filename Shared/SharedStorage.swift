//
//  SharedStorage.swift
//  Easymode
//
//  Shared storage utilities for communication between the main app and the
//  Family Controls extensions. Uses App Groups to share data across processes.
//
//  This file is linked into: Main App, DeviceActivityMonitorExtension,
//  ShieldConfigurationExtension, ShieldActionExtension.
//

import Foundation
import os
#if canImport(FamilyControls)
import FamilyControls
#endif

// MARK: - Shared logging

/// Unified subsystem name used by every EasyMode binary.
/// `os.Logger` instances created with this subsystem show up together in
/// Console.app / `log stream --predicate 'subsystem == "name.erikkernan.easymode"'`.
public let easyModeLogSubsystem = "name.erikkernan.easymode"

/// Factory for category-scoped loggers. Keeps the subsystem string in one place.
@inlinable
public func easyModeLogger(_ category: String) -> Logger {
    Logger(subsystem: easyModeLogSubsystem, category: category)
}

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
    private static let fallbackSubtitle = "This can wait until your session is done."
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
                subtitle = "\(appName) can wait until your session is done."
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

    /// Whether the user has completed onboarding (backup of UserDefaults.standard)
    case hasCompletedOnboarding = "EasyMode.HasCompletedOnboarding"

    /// Whether to auto-show the Screen Time permissions prompt.
    /// Set to false after onboarding completes so the sheet never reappears.
    case shouldAutoPromptForPermissions = "EasyMode.ShouldAutoPromptForPermissions"
}

/// Provides shared storage access across app and extensions
final class SharedStorage {

    private static let log = easyModeLogger("SharedStorage")

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
        Self.log.warning(
            "App Group '\(Self.appGroupIdentifier, privacy: .public)' unavailable — "
                + "falling back to standard UserDefaults (extensions may not see shared state)."
        )
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
            Self.log.error("Failed to save app selection: \(String(describing: error), privacy: .public)")
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
            Self.log.error("Failed to load app selection: \(String(describing: error), privacy: .public)")
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

    // MARK: - Onboarding State

    /// Whether onboarding has been completed (App Group only).
    /// For launch gating, use `mergeOnboardingCompletionFromAllStores()` then read
    /// `UserDefaults.standard` key `hasCompletedOnboarding` or `@AppStorage` — those stay aligned after merge.
    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: SharedStorageKey.hasCompletedOnboarding.rawValue)
    }

    /// Persists the onboarding completion flag to the App Group.
    /// Call `mergeOnboardingCompletionFromAllStores()` after this (or from app completion) so
    /// `UserDefaults.standard` matches `@AppStorage("hasCompletedOnboarding")`.
    func setHasCompletedOnboarding(_ completed: Bool) {
        defaults.set(completed, forKey: SharedStorageKey.hasCompletedOnboarding.rawValue)
    }

    /// Keeps App Group and `UserDefaults.standard` (`@AppStorage("hasCompletedOnboarding")`) in sync.
    /// Either store may have been written first; after merge, both reflect completion if *either* was true.
    func mergeOnboardingCompletionFromAllStores() {
        let groupComplete = defaults.bool(forKey: SharedStorageKey.hasCompletedOnboarding.rawValue)
        let standardComplete = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        guard groupComplete || standardComplete else { return }
        if groupComplete, !standardComplete {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
        if standardComplete, !groupComplete {
            defaults.set(true, forKey: SharedStorageKey.hasCompletedOnboarding.rawValue)
        }
        // Legacy installs completed onboarding before `shouldAutoPromptForPermissions` existed.
        // A missing key used to mean "auto-prompt every launch" (see shouldAutoPromptForPermissions).
        let autoPromptKeyPresent =
            defaults.object(forKey: SharedStorageKey.shouldAutoPromptForPermissions.rawValue) != nil
        if !autoPromptKeyPresent {
            setShouldAutoPromptForPermissions(false)
        }
    }

    /// Whether to auto-prompt for Screen Time permissions from **AppTabView** on launch.
    /// Screen Time permission during first-run onboarding is handled inside `OnboardingView`, not here.
    /// A **missing** key must read as **false**: legacy installs otherwise hit `nil || …` and got `true`,
    /// which re-opened the permissions sheet every cold launch when authorization was still denied.
    func shouldAutoPromptForPermissions() -> Bool {
        guard defaults.object(forKey: SharedStorageKey.shouldAutoPromptForPermissions.rawValue) != nil else {
            return false
        }
        return defaults.bool(forKey: SharedStorageKey.shouldAutoPromptForPermissions.rawValue)
    }

    /// Sets whether to auto-prompt for Screen Time permissions
    func setShouldAutoPromptForPermissions(_ shouldPrompt: Bool) {
        defaults.set(shouldPrompt, forKey: SharedStorageKey.shouldAutoPromptForPermissions.rawValue)
    }
}

// MARK: - CaseIterable for Keys

extension SharedStorageKey: CaseIterable {}

