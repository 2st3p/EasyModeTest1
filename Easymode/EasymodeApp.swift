//
//  EasymodeApp.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// The main app structure that serves as the entry point for the Easymode application.
/// This file configures the app's data model and sets up the main navigation structure.
@main
struct EasymodeApp: App {
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
            SharedStorage.shared.setHasCompletedOnboarding(false)
            SharedStorage.shared.setShouldAutoPromptForPermissions(true)
        }

        // UI Testing: Simulate already-completed onboarding for relaunch tests
        if processInfo.environment["UI_TEST_HAS_COMPLETED_ONBOARDING"] == "true" {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            SharedStorage.shared.setHasCompletedOnboarding(true)
            SharedStorage.shared.setShouldAutoPromptForPermissions(false)
        }

        // Keep @AppStorage key and App Group backup aligned (either may have been written first).
        SharedStorage.shared.mergeOnboardingCompletionFromAllStores()
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

    /// Gate for main vs onboarding **after** launch resolves. Uses explicit state read from
    /// `UserDefaults` (synced with App Group via `merge…`) so we never paint `OnboardingView`
    /// for a frame while `@AppStorage` is still catching up to disk.
    @State private var resolvedShowsMainApp: Bool = {
        SharedStorage.shared.mergeOnboardingCompletionFromAllStores()
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }()

    var body: some View {
        Group {
            if !hasResolvedLaunchState {
                // Deferred resolution: avoid first-frame @AppStorage default flash.
                // Show neutral background until launch state is confirmed.
                Color.parchment
                    .ignoresSafeArea()
            } else if resolvedShowsMainApp {
                AppTabView()
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        resolvedShowsMainApp = true
                        hasCompletedOnboarding = true
                        SharedStorage.shared.setHasCompletedOnboarding(true)
                        SharedStorage.shared.setShouldAutoPromptForPermissions(false)
                        SharedStorage.shared.mergeOnboardingCompletionFromAllStores()
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
                        && processInfo.environment[EasymodeApp.uiTestResetStateKey] == "true"
                )
            } catch {
                print("⚠️ Failed to prepare launch state: \(error)")
            }

            SharedStorage.shared.mergeOnboardingCompletionFromAllStores()
            let showsMain = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            resolvedShowsMainApp = showsMain
            if showsMain {
                hasCompletedOnboarding = true
            }

            hasResolvedLaunchState = true
        }
    }
}
