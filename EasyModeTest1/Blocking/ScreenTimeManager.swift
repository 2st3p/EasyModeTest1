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
    
    /// Whether a focus session is currently active (apps are blocked)
    @Published private(set) var isFocusActive = false
    
    /// Current error state for UI display
    @Published var error: ScreenTimeError?
    
    #if canImport(FamilyControls)
    /// The user's app selection from FamilyActivityPicker
    @Published var activitySelection = FamilyActivitySelection()
    #endif
    
    // MARK: - Private Properties
    
    #if canImport(FamilyControls)
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
    
    // MARK: - Initialization
    
    private init() {
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
        guard isAuthorized else {
            throw ScreenTimeError.notAuthorized
        }
        
        // Save current task text for shield display
        saveCurrentTask(taskText)
        
        // Apply shields to selected apps
        applyShields()
        
        // Schedule device activity for persistence
        try scheduleActivity()
        
        isFocusActive = true
        
        #else
        // Simulator fallback
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
        
        isFocusActive = false
        
        #else
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
    }
    
    /// Loads the saved app selection from UserDefaults
    private func loadSavedSelection() {
        activitySelection = SharedStorage.shared.loadSelection() ?? FamilyActivitySelection()
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
        return !activitySelection.applicationTokens.isEmpty ||
               !activitySelection.categoryTokens.isEmpty
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


