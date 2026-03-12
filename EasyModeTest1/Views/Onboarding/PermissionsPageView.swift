//
//  PermissionsPageView.swift
//  EasyModeTest1
//
//  Second onboarding screen: Screen Time permissions
//  Explains why the app needs permissions and triggers the system prompt.
//

import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

/// Permissions page for requesting Screen Time authorization
struct PermissionsPageView: View {
    /// Screen Time manager for authorization
    @ObservedObject var screenTimeManager: ScreenTimeManager
    
    /// Callback when permissions are granted
    let onContinue: () -> Void
    
    /// Loading state during authorization
    @State private var isRequesting = false
    
    /// Error message to display
    @State private var errorMessage: String?
    
    /// Animation states
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Main content
            VStack(spacing: 32) {
                // Shield icon
                ZStack {
                    Circle()
                        .fill(Color.secondaryPink.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.secondaryPink)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                // Title
                VStack(spacing: 12) {
                    Text("Stay in the zone")
                        .font(.serifTitle(36))
                        .foregroundColor(.softBlack)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 10)
                
                // Explanation
                Text("Easy Mode needs Screen Time access to block distracting apps during your focus sessions.")
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
            
            // Info card
            VStack(spacing: 16) {
                InfoRow(
                    icon: "lock.shield",
                    title: "Your data stays private",
                    description: "We never see which apps you use or block."
                )
                
                InfoRow(
                    icon: "hand.raised.fill",
                    title: "You're in control",
                    description: "Change your blocked apps anytime in settings."
                )
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.sansSmall(14))
                    .foregroundColor(.destructive)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
            
            // Grant permission button
            Button(action: requestPermission) {
                HStack(spacing: 12) {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 18))
                    }
                    Text(isRequesting ? "Requesting..." : "Grant Permission")
                        .font(.sansMedium(18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryOrange)
                .cornerRadius(999)
                .paperShadow()
            }
            .buttonStyle(.plain)
            .disabled(isRequesting)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
        .parchmentBackground()
        .onAppear {
            animateIn()
            // Check if already authorized
            if screenTimeManager.isAuthorized {
                onContinue()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
            showContent = true
        }
    }
    
    private func requestPermission() {
        HapticManager.shared.impact()
        isRequesting = true
        errorMessage = nil
        
        #if targetEnvironment(simulator)
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            isRequesting = false
            onContinue()
            return
        }
        // Simulator: skip permission (FamilyControls doesn't work in simulator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isRequesting = false
            HapticManager.shared.success()
            onContinue()
        }
        #else
        #if canImport(FamilyControls)
        Task {
            do {
                try await screenTimeManager.requestAuthorization()
                await MainActor.run {
                    isRequesting = false
                    if screenTimeManager.isAuthorized {
                        HapticManager.shared.success()
                        onContinue()
                    } else {
                        errorMessage = "Permission is required to continue."
                    }
                }
            } catch {
                await MainActor.run {
                    isRequesting = false
                    HapticManager.shared.error()
                    errorMessage = "Permission denied. Please enable in Settings > Screen Time."
                }
            }
        }
        #endif
        #endif
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.secondaryPink)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .cornerRadius(10)
                .paperShadow()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.sansMedium(16))
                    .foregroundColor(.softBlack)
                
                Text(description)
                    .font(.sansSmall(14))
                    .foregroundColor(.mutedForeground)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PermissionsPageView(
        screenTimeManager: ScreenTimeManager.shared,
        onContinue: {}
    )
}
