//
//  OnboardingView.swift
//  Easymode
//
//  Main onboarding flow container that guides users through
//  value proposition, permissions, and initial app selection.
//

import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

/// Container view for the onboarding flow
/// Manages navigation between onboarding screens and completion state
struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage: OnboardingPage = .welcome
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingProgressView(currentPage: currentPage)
                    .padding(.top, 16)
                    .padding(.horizontal, 32)

                TabView(selection: $currentPage) {
                    WelcomePageView(onContinue: { advanceToPage(.permissions) })
                        .tag(OnboardingPage.welcome)

                    PermissionsPageView(
                        screenTimeManager: screenTimeManager,
                        onContinue: { advanceToPage(.appSelection) }
                    )
                    .tag(OnboardingPage.permissions)

                    AppSelectionPageView(
                        screenTimeManager: screenTimeManager,
                        onComplete: onComplete
                    )
                    .tag(OnboardingPage.appSelection)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? .linear(duration: 0.001) : .spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
            }
        }
    }

    private func advanceToPage(_ page: OnboardingPage) {
        if reduceMotion {
            currentPage = page
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPage = page
            }
        }
    }
}

// MARK: - Onboarding Page Enum

enum OnboardingPage: Int, CaseIterable {
    case welcome = 0
    case permissions = 1
    case appSelection = 2
}

// MARK: - Progress Indicator

struct OnboardingProgressView: View {
    let currentPage: OnboardingPage
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingPage.allCases, id: \.rawValue) { page in
                Capsule()
                    .fill(page.rawValue <= currentPage.rawValue ? Color.primaryChartreuse : Color.borderColor.opacity(0.3))
                    .frame(height: 3)
                    .animation(.spring(response: 0.4), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
