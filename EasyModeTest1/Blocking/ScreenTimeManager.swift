//
//  ScreenTimeManager.swift
//  EasyModeTest1
//
//  Central manager for Screen Time app blocking functionality.
//  Handles authorization, app selection storage, and shield management.
//

import Foundation
import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import DeviceActivity
#endif

/// Manages Screen Time-based app blocking for focus sessions.
/// Uses Apple's FamilyControls, ManagedSettings, and DeviceActivity frameworks.
@MainActor
final class ScreenTimeManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ScreenTimeManager()
    
    // MARK: - Published Properties
    
    /// Whether Screen Time authorization has been granted
    @Published private(set) var isAuthorized = false

    /// Whether authorization status has been checked (used to prevent UI flashes during startup)
    @Published private(set) var hasCheckedAuthorization = false

    /// Whether a focus session is currently active (apps are blocked)
    @Published private(set) var isFocusActive = false
    
    /// Current error state for UI display
    @Published var error: ScreenTimeError?
    
    #if canImport(FamilyControls)
    /// The user's app selection from FamilyActivityPicker
    @Published var activitySelection = ScreenTimeManager.makeSelection()
    #endif
    
    // MARK: - Private Properties
    
    #if canImport(FamilyControls)
    private static func makeSelection() -> FamilyActivitySelection {
        FamilyActivitySelection(includeEntireCategory: true)
    }

    private static func normalizedSelection(_ selection: FamilyActivitySelection) -> FamilyActivitySelection {
        var normalizedSelection = makeSelection()
        normalizedSelection.applicationTokens = selection.applicationTokens
        normalizedSelection.categoryTokens = selection.categoryTokens
        normalizedSelection.webDomainTokens = selection.webDomainTokens
        return normalizedSelection
    }

    /// ManagedSettingsStore for applying restrictions
    private let store = ManagedSettingsStore()
    
    /// Activity name for DeviceActivity scheduling
    private let activityName = DeviceActivityName("EasyMode.FocusSession")
    
    /// DeviceActivityCenter for scheduling activities
    private let activityCenter = DeviceActivityCenter()
    #endif
    
    /// App Group identifier for sharing data with extensions
    /// Note: Update this with your actual App Group identifier
    static let appGroupIdentifier = SharedStorage.appGroupIdentifier

    static func selectionCount(
        applicationCount: Int,
        categoryCount: Int,
        webDomainCount: Int
    ) -> Int {
        applicationCount + categoryCount + webDomainCount
    }

    static func hasAnySelection(
        applicationCount: Int,
        categoryCount: Int,
        webDomainCount: Int
    ) -> Bool {
        selectionCount(
            applicationCount: applicationCount,
            categoryCount: categoryCount,
            webDomainCount: webDomainCount
        ) > 0
    }
    
    // MARK: - Initialization
    
    private init() {
        isFocusActive = SharedStorage.shared.isFocusActive()
        #if canImport(FamilyControls)
        loadSavedSelection()
        Task {
            await checkAuthorizationStatus()
        }
        #endif
    }
    
    // MARK: - Authorization
    
    #if canImport(FamilyControls)
    /// Checks and updates the current authorization status
    func checkAuthorizationStatus() async {
        let status = AuthorizationCenter.shared.authorizationStatus
        isAuthorized = (status == .approved)
        hasCheckedAuthorization = true
    }
    
    /// Requests Screen Time authorization from the user
    /// - Throws: ScreenTimeError if authorization fails
    func requestAuthorization() async throws {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            await checkAuthorizationStatus()
            
            if !isAuthorized {
                throw ScreenTimeError.authorizationDenied
            }
        } catch let error as FamilyControlsError {
            throw ScreenTimeError.authorizationFailed(error.localizedDescription)
        } catch {
            throw ScreenTimeError.authorizationFailed(error.localizedDescription)
        }
    }
    #endif
    
    // MARK: - Focus Session Control
    
    /// Starts a focus session - blocks selected apps
    /// - Parameter taskText: The current task text to display on shields
    func startFocusSession(taskText: String) throws {
        #if canImport(FamilyControls)
        // Re-read the live authorization state so a cold-launch race does not
        // incorrectly reject blocking before the async status check finishes.
        isAuthorized = (AuthorizationCenter.shared.authorizationStatus == .approved)

        guard isAuthorized else {
            throw ScreenTimeError.notAuthorized
        }
        
        // Save current task text for shield display
        saveCurrentTask(taskText)
        
        // Apply shields to selected apps
        applyShields()
        
        // Schedule device activity for persistence
        try scheduleActivity()
        
        SharedStorage.shared.setFocusActive(true)
        isFocusActive = true
        
        #else
        // Simulator fallback
        SharedStorage.shared.setFocusActive(true)
        isFocusActive = true
        #endif
    }
    
    /// Ends the current focus session - unblocks all apps
    func endFocusSession() {
        #if canImport(FamilyControls)
        // Remove all shields
        removeShields()
        
        // Stop scheduled activity
        activityCenter.stopMonitoring([activityName])
        
        // Clear current task
        clearCurrentTask()
        
        SharedStorage.shared.setFocusActive(false)
        isFocusActive = false
        
        #else
        SharedStorage.shared.setFocusActive(false)
        isFocusActive = false
        #endif
    }
    
    // MARK: - Shield Management
    
    #if canImport(FamilyControls)
    /// Applies shields to all selected apps
    private func applyShields() {
        // Shield selected applications
        store.shield.applications = activitySelection.applicationTokens
        
        // Shield selected categories
        store.shield.applicationCategories = .specific(activitySelection.categoryTokens)
        
        // Shield web domains (if any selected)
        store.shield.webDomains = activitySelection.webDomainTokens
    }
    
    /// Removes all shields
    private func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    #endif
    
    // MARK: - DeviceActivity Scheduling
    
    #if canImport(FamilyControls)
    /// Schedules a DeviceActivity for persistent blocking
    /// This ensures blocking persists even if the app is terminated
    private func scheduleActivity() throws {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: false
        )
        
        do {
            try activityCenter.startMonitoring(activityName, during: schedule)
        } catch {
            throw ScreenTimeError.schedulingFailed(error.localizedDescription)
        }
    }
    #endif
    
    // MARK: - Persistence
    
    #if canImport(FamilyControls)
    /// Saves the current app selection to UserDefaults
    private func saveSelection() {
        SharedStorage.shared.saveSelection(activitySelection)
    }

    /// Persists the current selection when the user finishes editing
    func persistSelection() {
        saveSelection()
        if isFocusActive {
            applyShields()
            // Update Live Activity to reflect new blocking state
            Task {
                await LiveActivityManager.shared.updateBlockingState(isBlocking: hasSelectedApps)
            }
        }
    }
    
    /// Loads the saved app selection from UserDefaults
    private func loadSavedSelection() {
        if let savedSelection = SharedStorage.shared.loadSelection() {
            activitySelection = Self.normalizedSelection(savedSelection)
        } else {
            activitySelection = Self.makeSelection()
        }
    }
    #endif
    
    /// Saves the current task text for shield display
    private func saveCurrentTask(_ taskText: String) {
        SharedStorage.shared.setCurrentTask(taskText)
    }
    
    /// Clears the current task text
    private func clearCurrentTask() {
        SharedStorage.shared.clearCurrentTask()
    }
    
    /// Retrieves the current task text (used by Shield extension)
    static func getCurrentTask() -> String? {
        SharedStorage.shared.getCurrentTask()
    }
    
    // MARK: - Convenience
    
    /// Whether there are any apps selected for blocking
    var hasSelectedApps: Bool {
        #if canImport(FamilyControls)
        return Self.hasAnySelection(
            applicationCount: activitySelection.applicationTokens.count,
            categoryCount: activitySelection.categoryTokens.count,
            webDomainCount: activitySelection.webDomainTokens.count
        )
        #else
        return false
        #endif
    }
}

// MARK: - Error Types

/// Errors that can occur during Screen Time operations
enum ScreenTimeError: LocalizedError {
    case notAuthorized
    case authorizationDenied
    case authorizationFailed(String)
    case schedulingFailed(String)
    case persistenceFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Screen Time access is required. Please grant permission in Settings."
        case .authorizationDenied:
            return "Screen Time authorization was denied. Please enable it in Settings > Screen Time."
        case .authorizationFailed(let message):
            return "Failed to authorize Screen Time: \(message)"
        case .schedulingFailed(let message):
            return "Failed to schedule focus session: \(message)"
        case .persistenceFailed(let message):
            return "Failed to save settings: \(message)"
        }
    }
}
