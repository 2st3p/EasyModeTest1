//
//  WelcomePageView.swift
//  EasyModeTest1
//
//  First onboarding screen: Value proposition
//  Introduces the app's core concept and benefits.
//

import SwiftUI

/// Welcome page explaining the app's value proposition
struct WelcomePageView: View {
    /// Callback when user is ready to continue
    let onContinue: () -> Void
    
    /// Animation states
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showFeatures = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Main content
            VStack(spacing: 32) {
                // App icon/logo placeholder
                ZStack {
                    Circle()
                        .fill(Color.primaryChartreuse.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "target")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundColor(.primaryChartreuse)
                }
                .scaleEffect(showTitle ? 1 : 0.5)
                .opacity(showTitle ? 1 : 0)
                
                // Title
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.sansBody(16))
                        .foregroundColor(.mutedForeground)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 10)
                    
                    Text("Easy Mode")
                        .font(.serifTitle(44))
                        .foregroundColor(.softBlack)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 10)
                }
                
                // Subtitle
                Text("Focus on one thing.\nAccomplish more.")
                    .font(.serifBody(20))
                    .foregroundColor(.softBlack.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(showSubtitle ? 1 : 0)
                    .offset(y: showSubtitle ? 0 : 15)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Features list
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    text: "Choose your single focus"
                )
                .opacity(showFeatures ? 1 : 0)
                .offset(x: showFeatures ? 0 : -20)
                
                FeatureRow(
                    icon: "shield.fill",
                    text: "Block distracting apps"
                )
                .opacity(showFeatures ? 1 : 0)
                .offset(x: showFeatures ? 0 : -20)
                
                FeatureRow(
                    icon: "sparkles",
                    text: "Celebrate your wins"
                )
                .opacity(showFeatures ? 1 : 0)
                .offset(x: showFeatures ? 0 : -20)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue button
            Button(action: {
                HapticManager.shared.impact()
                onContinue()
            }) {
                Text("Get Started")
                    .font(.sansMedium(18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryChartreuse)
                    .cornerRadius(999)
                    .paperShadow()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
        }
        .parchmentBackground()
        .onAppear {
            animateIn()
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
            showTitle = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
            showSubtitle = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
            showFeatures = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7)) {
            showButton = true
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.primaryChartreuse)
                .frame(width: 32)
            
            Text(text)
                .font(.sansBody(16))
                .foregroundColor(.softBlack)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

#Preview {
    WelcomePageView(onContinue: {})
}

