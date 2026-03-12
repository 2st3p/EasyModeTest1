//
//  EasyModeTest1App.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// The main app structure that serves as the entry point for the EasyMode application.
/// This file configures the app's data model and sets up the main navigation structure.
@main
struct EasyModeTest1App: App {
    fileprivate static let uiTestResetStateKey = "UI_TEST_RESET_STATE"

    /// Tracks whether the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    /// Deferred resolution: prevents @AppStorage from briefly showing default (false)
    /// on first frame before persisted value is read, which caused onboarding flash.
    @State private var hasResolvedLaunchState = false

    init() {
        let processInfo = ProcessInfo.processInfo
        let shouldResetForUITesting =
            processInfo.arguments.contains("-ui-testing")
            && processInfo.environment[Self.uiTestResetStateKey] == "true"

        // UI Testing: Reset onboarding for fresh test runs
        if shouldResetForUITesting {
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }

        // UI Testing: Simulate already-completed onboarding for relaunch tests
        if processInfo.environment["UI_TEST_HAS_COMPLETED_ONBOARDING"] == "true" {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }
    
    /// Configures the SwiftData model container for persistent storage
    /// This container manages the app's data model and provides the context for data operations
    var sharedModelContainer: ModelContainer = {
        // Define the schema for the app's data model
        let schema = Schema([
            Item.self,  // Currently using a basic Item model for task storage
            BlockedApp.self,  // Add BlockedApp to the schema
        ])
        // Configure the model to store data persistently (not in memory only)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LaunchRootView(
                hasCompletedOnboarding: $hasCompletedOnboarding,
                hasResolvedLaunchState: $hasResolvedLaunchState
            )
        }
        .modelContainer(sharedModelContainer)  // Provides the data model context to all views
    }
}

private struct LaunchRootView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var hasResolvedLaunchState: Bool

    @Environment(\.modelContext) private var modelContext

    private let processInfo = ProcessInfo.processInfo

    var body: some View {
        Group {
            if !hasResolvedLaunchState {
                // Deferred resolution: avoid first-frame @AppStorage default flash.
                // Show neutral background until launch state is confirmed.
                Color.parchment
                    .ignoresSafeArea()
            } else if hasCompletedOnboarding {
                AppTabView()
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .task {
            // Yield one run loop so @AppStorage has the correct persisted value
            // before we decide which view to show. Prevents onboarding flash.
            await Task.yield()

            do {
                try LaunchStateCoordinator.prepareForLaunch(
                    modelContext: modelContext,
                    shouldResetForUITesting: processInfo.arguments.contains("-ui-testing")
                        && processInfo.environment[EasyModeTest1App.uiTestResetStateKey] == "true"
                )
            } catch {
                print("⚠️ Failed to prepare launch state: \(error)")
            }

            hasResolvedLaunchState = true
        }
    }
}
