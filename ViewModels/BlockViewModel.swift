//
//  BlockViewModel.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import Foundation
import SwiftData
#if canImport(FamilyControls)
import FamilyControls
#endif

/// ViewModel for managing app blocking functionality
/// Handles app selection, authorization, and persistence of blocked apps
/// Now integrates with ScreenTimeManager for actual blocking
@MainActor
final class BlockViewModel: ObservableObject {
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Whether an error alert should be shown
    @Published var showError: Bool = false
    
    #if canImport(FamilyControls)
    /// The current selection from FamilyActivityPicker
    /// Synced with ScreenTimeManager for actual blocking
    @Published var selection: FamilyActivitySelection {
        didSet {
            // Sync selection with ScreenTimeManager
            ScreenTimeManager.shared.activitySelection = selection
        }
    }
    
    /// Whether Screen Time authorization has been granted
    @Published var isAuthorized = false
    
    /// Whether authorization is currently being requested
    @Published var isRequestingAuth = false
    #endif
    
    /// Reference to the shared ScreenTimeManager
    private let screenTimeManager = ScreenTimeManager.shared
    
    init() {
        #if canImport(FamilyControls)
        // Initialize with ScreenTimeManager's selection
        self.selection = ScreenTimeManager.shared.activitySelection
        self.isAuthorized = ScreenTimeManager.shared.isAuthorized
        #endif
    }
    
    #if canImport(FamilyControls)
    /// Refreshes the authorization status from ScreenTimeManager
    func refreshAuthorizationStatus() async {
        await screenTimeManager.checkAuthorizationStatus()
        isAuthorized = screenTimeManager.isAuthorized
    }
    
    /// Requests Screen Time authorization
    func requestAuthorization() async {
        isRequestingAuth = true
        do {
            try await screenTimeManager.requestAuthorization()
            isAuthorized = screenTimeManager.isAuthorized
        } catch {
            handleError(BlockError.authorizationFailed(error.localizedDescription))
        }
        isRequestingAuth = false
    }
    
    /// Syncs the current selection from ScreenTimeManager
    func syncSelection() {
        selection = screenTimeManager.activitySelection
    }
    #endif
    
    /// Saves the selected apps to the data store
    /// Removes apps that are no longer selected and adds newly selected apps
    func saveSelectedApps(_ blockedApps: [BlockedApp], using modelContext: ModelContext) throws {
        #if canImport(FamilyControls)
        let existingBundleIDs = Set(blockedApps.map(\.bundleID))
        var hasChanges = false
        
        // Remove apps no longer selected
        for app in blockedApps {
            let isStillSelected = selection.applications.contains { token in
                guard let id = token.bundleIdentifier else { return false }
                return id == app.bundleID
            }
            if !isStillSelected {
                modelContext.delete(app)
                hasChanges = true
            }
        }
        
        // Add newly selected apps
        for token in selection.applications {
            guard let bundleID = token.bundleIdentifier else { continue }
            if !existingBundleIDs.contains(bundleID) {
                let name = bundleID.components(separatedBy: ".").last ?? bundleID
                modelContext.insert(BlockedApp(bundleID: bundleID, appName: name))
                hasChanges = true
            }
        }
        
        // Only save if there were changes
        if hasChanges {
            do {
                try modelContext.save()
            } catch {
                throw BlockError.saveFailed(error.localizedDescription)
            }
        }
        #else
        // Fallback for simulator/development - this method should not be called
        // when FamilyControls is not available, use saveMockSelectedApps instead
        throw BlockError.saveFailed("FamilyControls not available, use saveMockSelectedApps instead")
        #endif
    }
    
    /// Saves selected apps from a mock selection (for simulator/development)
    func saveMockSelectedApps(_ selectedBundleIDs: Set<String>, from blockedApps: [BlockedApp], using modelContext: ModelContext) throws {
        var hasChanges = false
        
        // Remove apps that are no longer selected
        for app in blockedApps {
            if !selectedBundleIDs.contains(app.bundleID) {
                modelContext.delete(app)
                hasChanges = true
            }
        }
        
        // Add newly selected apps
        let existingBundleIDs = Set(blockedApps.map(\.bundleID))
        for bundleID in selectedBundleIDs {
            if !existingBundleIDs.contains(bundleID) {
                let appName = bundleID.components(separatedBy: ".").last ?? bundleID
                modelContext.insert(BlockedApp(bundleID: bundleID, appName: appName))
                hasChanges = true
            }
        }
        
        // Only save if there were changes
        if hasChanges {
            do {
                try modelContext.save()
            } catch {
                throw BlockError.saveFailed(error.localizedDescription)
            }
        }
    }
    
    /// Deletes apps at the specified indices
    func deleteApps(at offsets: IndexSet, from blockedApps: [BlockedApp], using modelContext: ModelContext) throws {
        for index in offsets {
            modelContext.delete(blockedApps[index])
        }
        
        do {
            try modelContext.save()
        } catch {
            throw BlockError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Handles errors by setting the error message and showing the alert
    func handleError(_ error: Error) {
        if let blockError = error as? BlockError {
            errorMessage = blockError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}

/// Errors that can occur during block operations
enum BlockError: LocalizedError {
    case authorizationFailed(String)
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let message):
            return "Failed to authorize Screen Time access: \(message)"
        case .saveFailed(let message):
            return "Failed to save blocked apps: \(message)"
        }
    }
}
