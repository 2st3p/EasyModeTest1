//
//  EasymodeApp.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData
import os

/// The main app structure that serves as the entry point for the Easymode application.
/// This file configures the app's data model and sets up the main navigation structure.
@main
struct EasymodeApp: App {
    fileprivate static let uiTestResetStateKey = "UI_TEST_RESET_STATE"
    private static let log = easyModeLogger("SwiftData")

    /// Persistent store first; falls back to in-memory so the app stays usable if disk fails.
    private static func makeSharedModelContainer() -> ModelContainer? {
        let schema = Schema([
            Item.self,
            BlockedApp.self,
        ])
        let persistent = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [persistent])
        } catch {
            Self.log.error("Persistent ModelContainer failed: \(error.localizedDescription, privacy: .public)")
            let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [memory])
            } catch {
                Self.log.critical("In-memory ModelContainer also failed: \(String(describing: error), privacy: .public)")
                return nil
            }
        }
    }

    /// Lazily created after `init()` runs so UI-test environment mutations apply first.
    private static let sharedModelContainer: ModelContainer? = Self.makeSharedModelContainer()

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

        _ = Self.sharedModelContainer
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = Self.sharedModelContainer {
                    LaunchRootView(
                        hasCompletedOnboarding: $hasCompletedOnboarding,
                        hasResolvedLaunchState: $hasResolvedLaunchState
                    )
                    .modelContainer(container)
                } else {
                    StorageUnavailableView()
                }
            }
        }
    }
}

// MARK: - Storage failure UI

private struct StorageUnavailableView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(String(localized: "storage.unavailable.title"))
                .font(.title2.weight(.semibold))
            Text(String(localized: "storage.unavailable.detail"))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct LaunchRootView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var hasResolvedLaunchState: Bool

    @Environment(\.modelContext) private var modelContext

    private let processInfo = ProcessInfo.processInfo
    private static let log = easyModeLogger("Launch")

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
                Self.log.error("prepareForLaunch failed: \(error.localizedDescription, privacy: .public)")
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
