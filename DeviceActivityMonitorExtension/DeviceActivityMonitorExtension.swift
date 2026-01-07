//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  DeviceActivity extension that runs in the background to monitor and enforce
//  app blocking during focus sessions. This extension persists even when the
//  main app is terminated.
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Device Activity Monitor Extension"
//  3. Name it "DeviceActivityMonitorExtension"
//  4. Add this file to the new target
//  5. Enable "App Groups" capability and add "group.com.easymode.shared"
//  6. Add the same App Group to your main app target
//

import DeviceActivity
import ManagedSettings
import FamilyControls
import Foundation

/// Extension point that monitors device activity and enforces blocking rules.
/// Runs in a separate process from the main app for persistence.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    /// ManagedSettingsStore for applying restrictions
    private let store = ManagedSettingsStore()
    
    // MARK: - DeviceActivityMonitor Callbacks
    
    /// Called when a monitored activity interval begins
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Reapply shields when activity starts
        applyStoredShields()
    }
    
    /// Called when a monitored activity interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Remove shields when activity ends
        removeAllShields()
    }
    
    /// Called when the device wakes up during a monitored interval
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Preemptively apply shields
        applyStoredShields()
    }
    
    /// Called when an event (threshold) is reached
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Could be used for time-based blocking in future
    }
    
    // MARK: - Shield Management
    
    /// Loads the stored app selection and applies shields
    private func applyStoredShields() {
        guard let selection = loadStoredSelection() else {
            return
        }
        
        // Apply shields to selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    
    /// Removes all active shields
    private func removeAllShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    /// Loads the FamilyActivitySelection from shared UserDefaults
    private func loadStoredSelection() -> FamilyActivitySelection? {
        SharedStorage.shared.loadSelection()
    }
}



