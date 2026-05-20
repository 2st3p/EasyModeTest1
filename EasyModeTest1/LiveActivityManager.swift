//
//  LiveActivityManager.swift
//  EasyModeTest1
//
//  Manages the lifecycle of Focus Session Live Activities.
//  Handles starting, updating, and ending activities on Lock Screen and Dynamic Island.
//

import Foundation
import ActivityKit
import os

@MainActor
final class LiveActivityManager: ObservableObject {

    private static let log = easyModeLogger("LiveActivity")

    // MARK: - Singleton
    
    static let shared = LiveActivityManager()
    
    // MARK: - Properties
    
    /// The currently active Live Activity, if any
    private var currentActivity: Activity<FocusActivityAttributes>?
    
    /// Whether Live Activities are supported on this device
    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods

    private func activitiesForMutation() -> [Activity<FocusActivityAttributes>] {
        if let currentActivity {
            return [currentActivity]
        }

        let existingActivities = Array(Activity<FocusActivityAttributes>.activities)
        currentActivity = existingActivities.last
        return existingActivities
    }
    
    /// Starts a new Live Activity for a focus session
    /// - Parameters:
    ///   - taskText: The task being focused on
    ///   - isBlocking: Whether app blocking is active
    ///   - startTime: When the focus session started (defaults to now)
    func startFocusActivity(taskText: String, isBlocking: Bool, startTime: Date = Date()) async {
        guard isSupported else {
            Self.log.notice("Live Activities not enabled or unsupported on this device.")
            return
        }
        
        // End any existing activities first (handles orphans from app kill/crash)
        await endAllActivities()
        
        let attributes = FocusActivityAttributes(
            taskText: taskText,
            startTime: startTime
        )
        
        let state = FocusActivityAttributes.ContentState(isBlocking: isBlocking)
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            Self.log.notice("Live Activity started (blocking=\(isBlocking, privacy: .public)).")
        } catch {
            Self.log.error("Failed to start Live Activity: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    /// Updates the blocking state of the current Live Activity
    /// - Parameter isBlocking: Whether app blocking is active
    func updateBlockingState(isBlocking: Bool) async {
        let state = FocusActivityAttributes.ContentState(isBlocking: isBlocking)
        let content = ActivityContent(state: state, staleDate: nil)

        let activities = activitiesForMutation()
        guard !activities.isEmpty else { return }

        for activity in activities {
            await activity.update(content)
        }
    }
    
    /// Ends the current Live Activity
    /// - Parameter completed: Whether the task was completed (vs cancelled)
    func endFocusActivity(completed: Bool = false) async {
        let finalState = FocusActivityAttributes.ContentState(isBlocking: false)
        let finalContent = ActivityContent(state: finalState, staleDate: nil)

        let activities = activitiesForMutation()
        guard !activities.isEmpty else { return }

        for activity in activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        Self.log.notice("Live Activity ended (completed=\(completed, privacy: .public)).")
    }
    
    /// Ends all active focus activities (cleanup)
    func endAllActivities() async {
        for activity in Activity<FocusActivityAttributes>.activities {
            let finalState = FocusActivityAttributes.ContentState(isBlocking: false)
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
