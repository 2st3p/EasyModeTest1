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
    /// Tracks whether the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
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
            if hasCompletedOnboarding {
                AppTabView()
            } else {
                OnboardingView {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)  // Provides the data model context to all views
    }
}
