//
//  AppTabView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

/// Main tab view with styled navigation matching DigitalDetoxCoach design
struct AppTabView: View {
    @State private var selectedTab = 0
    
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
}
