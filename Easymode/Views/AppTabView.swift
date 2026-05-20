//
//  AppTabView.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData
import UIKit

/// Root tab view: Home (focus), Log (history), Block (settings).
struct AppTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab = 0
    @State private var shouldShowPermissionsPrompt = false
    @State private var hasResolvedAuthorization = false
    @StateObject private var screenTimeManager = ScreenTimeManager.shared

    private static var chartreuseUIColor: UIColor {
        UIColor(
            red: BrandTokens.chartreuseRGB.red,
            green: BrandTokens.chartreuseRGB.green,
            blue: BrandTokens.chartreuseRGB.blue,
            alpha: 1
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskView()
                .tabItem {
                    Label(String(localized: "tab.home"), systemImage: "house.fill")
                }
                .tag(0)

            LogView()
                .tabItem {
                    Label(String(localized: "tab.log"), systemImage: "list.bullet")
                }
                .tag(1)

            BlockView()
                .tabItem {
                    Label(String(localized: "tab.block"), systemImage: "shield.fill")
                }
                .tag(2)
        }
        .environment(\.selectHomeTab, { selectedTab = 0 })
        .accessibilityIdentifier("tabs.root")
        .tint(.primaryChartreuse)
        .onAppear {
            configureTabBarAppearance()
        }
        .onChange(of: selectedTab) { _, _ in
            HapticManager.shared.selection()
        }
        .task {
            await refreshScreenTimeAuthorization()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
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
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.65)

        let normalGray = UIColor.secondaryLabel
        let chartreuse = Self.chartreuseUIColor
        let tabFont = UIFont.systemFont(ofSize: 11, weight: .medium)

        appearance.stackedLayoutAppearance.normal.iconColor = normalGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalGray,
            .font: tabFont
        ]

        appearance.stackedLayoutAppearance.selected.iconColor = chartreuse
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: chartreuse,
            .font: tabFont
        ]

        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.45)

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
        let shouldAutoPrompt = SharedStorage.shared.shouldAutoPromptForPermissions()
        shouldShowPermissionsPrompt = shouldAutoPrompt && !screenTimeManager.isAuthorized
        #endif
    }

    @MainActor
    private func refreshScreenTimeAuthorizationWithoutReset() async {
        #if targetEnvironment(simulator)
        shouldShowPermissionsPrompt = false
        #else
        await screenTimeManager.checkAuthorizationStatus()
        let shouldAutoPrompt = SharedStorage.shared.shouldAutoPromptForPermissions()
        shouldShowPermissionsPrompt = shouldAutoPrompt && !screenTimeManager.isAuthorized
        #endif
    }
}

#Preview {
    AppTabView()
        .modelContainer(for: [Item.self, BlockedApp.self], inMemory: true)
}
