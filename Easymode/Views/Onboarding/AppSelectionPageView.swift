//
//  AppSelectionPageView.swift
//  Easymode
//
//  Third onboarding screen: Initial app selection
//  Lets users choose which apps to block during focus sessions.
//

import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

/// App selection page for choosing initial blocked apps
struct AppSelectionPageView: View {
    /// Screen Time manager for app selection
    @ObservedObject var screenTimeManager: ScreenTimeManager
    
    /// Callback when onboarding is complete
    let onComplete: () -> Void

    /// Animation states
    @State private var showContent = false
    
    /// Selected apps count for display
    private var selectedAppsCount: Int {
        #if targetEnvironment(simulator)
        return 0
        #else
        #if canImport(FamilyControls)
        return ScreenTimeManager.selectionCount(
            applicationCount: screenTimeManager.activitySelection.applicationTokens.count,
            categoryCount: screenTimeManager.activitySelection.categoryTokens.count,
            webDomainCount: screenTimeManager.activitySelection.webDomainTokens.count
        )
        #else
        return 0
        #endif
        #endif
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Main content
            VStack(spacing: 32) {
                // Apps icon
                ZStack {
                    Circle()
                        .fill(Color.primaryChartreuse.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.primaryChartreuse)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                // Title
                VStack(spacing: 12) {
                    Text("What distracts you?")
                        .font(.serifTitle(36))
                        .foregroundColor(.softBlack)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                
                // Subtitle
                Text("Select the apps that pull you away from deep work. You can always change this later.")
                    .font(.sansBody(16))
                    .foregroundColor(.mutedForeground)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 15)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // App picker section
            VStack(spacing: 16) {
                #if targetEnvironment(simulator)
                // Simulator fallback
                SimulatorAppPicker()
                #else
                #if canImport(FamilyControls)
                // Real FamilyActivityPicker
                FamilyActivityPicker(selection: $screenTimeManager.activitySelection)
                    .frame(height: 280)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
                    )
                    .paperShadow()
                #else
                // Fallback for non-FamilyControls platforms
                SimulatorAppPicker()
                #endif
                #endif
                
                // Selection count
                if selectedAppsCount > 0 {
                    Text("\(selectedAppsCount) item\(selectedAppsCount == 1 ? "" : "s") selected")
                        .font(.sansSmall(14))
                        .foregroundColor(.primaryChartreuse)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Complete button
            Button(action: completeOnboarding) {
                HStack(spacing: 12) {
                    Text(selectedAppsCount > 0 ? "Let's Focus" : "Skip for Now")
                        .font(.sansMedium(18))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedAppsCount > 0 ? Color.primaryChartreuse : Color.mutedForeground)
                .cornerRadius(999)
                .paperShadow()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.spring(response: 0.4), value: selectedAppsCount)
        }
        .parchmentBackground()
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            showContent = true
        }
    }
    
    private func completeOnboarding() {
        HapticManager.shared.impact()
        #if canImport(FamilyControls)
        screenTimeManager.persistSelection()
        #endif
        onComplete()
    }
}

// MARK: - Simulator Fallback

/// Simulated app picker for the simulator
struct SimulatorAppPicker: View {
    @State private var selectedApps: Set<String> = []
    
    private let mockApps = [
        ("Instagram", "camera.fill"),
        ("TikTok", "play.rectangle.fill"),
        ("Twitter", "message.fill"),
        ("YouTube", "play.circle.fill"),
        ("Reddit", "bubble.left.and.bubble.right.fill"),
        ("Facebook", "person.2.fill")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("COMMON DISTRACTIONS")
                .font(.sansTiny(10))
                .foregroundColor(.mutedForeground.opacity(0.6))
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(mockApps, id: \.0) { app in
                        let isSelected = selectedApps.contains(app.0)
                        
                        Button(action: {
                            HapticManager.shared.selection()
                            if isSelected {
                                selectedApps.remove(app.0)
                            } else {
                                selectedApps.insert(app.0)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: app.1)
                                    .font(.system(size: 18))
                                    .foregroundColor(isSelected ? .primaryChartreuse : .mutedForeground)
                                    .frame(width: 36, height: 36)
                                    .background(isSelected ? Color.primaryChartreuse.opacity(0.1) : Color.mutedBackground)
                                    .cornerRadius(8)
                                
                                Text(app.0)
                                    .font(isSelected ? .sansMedium(16) : .sansBody(16))
                                    .foregroundColor(isSelected ? .softBlack : .mutedForeground)
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Color.primaryChartreuse : Color.clear)
                                        .frame(width: 24, height: 24)
                                    
                                    Circle()
                                        .stroke(isSelected ? Color.primaryChartreuse : Color.borderColor.opacity(0.3), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if app.0 != mockApps.last?.0 {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
            }
        }
        .frame(height: 280)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
        )
        .paperShadow()
    }
}

#Preview {
    AppSelectionPageView(
        screenTimeManager: ScreenTimeManager.shared,
        onComplete: {}
    )
}
