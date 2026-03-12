//
//  AppTabView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

/// Main tab view with styled navigation matching DigitalDetoxCoach design
struct AppTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var shouldShowPermissionsPrompt = false
    @State private var hasResolvedAuthorization = false
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TaskView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            LogView()
                .tabItem {
                    Label("Log", systemImage: "list.bullet")
                }
                .tag(1)
            
            BlockView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .accessibilityIdentifier("tabs.root")
        .tint(.primaryOrange)
        .onAppear {
            configureTabBarAppearance()
        }
        .task {
            await refreshScreenTimeAuthorization()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                // Re-check authorization when app becomes active, but don't reset
                // hasResolvedAuthorization to avoid flashing the permission sheet
                await refreshScreenTimeAuthorizationWithoutReset()
            }
        }
        .sheet(isPresented: Binding(
            get: { hasResolvedAuthorization && shouldShowPermissionsPrompt },
            set: { shouldShowPermissionsPrompt = $0 }
        )) {
            PermissionsPageView(
                screenTimeManager: screenTimeManager,
                onContinue: {
                    shouldShowPermissionsPrompt = false
                },
                autoContinueIfAuthorized: false
            )
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        // Blur effect background
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state - using the RGB values directly
        let primaryOrangeUIColor = UIColor(red: 0.988, green: 0.647, blue: 0.063, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.iconColor = primaryOrangeUIColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: primaryOrangeUIColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Border
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    @MainActor
    private func refreshScreenTimeAuthorization() async {
        #if targetEnvironment(simulator)
        hasResolvedAuthorization = true
        shouldShowPermissionsPrompt = false
        #else
        await screenTimeManager.checkAuthorizationStatus()
        hasResolvedAuthorization = true
        // Only show prompt if authorization check is complete and user is not authorized
        shouldShowPermissionsPrompt = !screenTimeManager.isAuthorized
        #endif
    }

    @MainActor
    private func refreshScreenTimeAuthorizationWithoutReset() async {
        #if targetEnvironment(simulator)
        shouldShowPermissionsPrompt = false
        #else
        await screenTimeManager.checkAuthorizationStatus()
        // Only update the prompt state, don't modify hasResolvedAuthorization
        shouldShowPermissionsPrompt = !screenTimeManager.isAuthorized
        #endif
    }
}
