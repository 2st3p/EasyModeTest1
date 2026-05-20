//
//  ActiveTaskView.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// Displays the current focus task and provides the commit / abandon affordances.
struct ActiveTaskView: View {
    private enum Completion {
        static let rippleDiameter: CGFloat = 80
        static let rippleEndScale: CGFloat = 4.0
        static let totalDuration: Double = 0.7
        static let successHapticDelay: Double = 0.18
    }

    let task: Item
    let onComplete: () -> Void
    let onCancel: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var completionSpace

    @State private var isCompleting = false
    @State private var showCancelAlert = false
    @State private var rippleScale: CGFloat = 1
    @State private var rippleOpacity: Double = 0.85
    @State private var completionTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if isCompleting && !reduceMotion {
                Circle()
                    .fill(Color.primaryChartreuse)
                    .frame(width: Completion.rippleDiameter, height: Completion.rippleDiameter)
                    .matchedGeometryEffect(id: "completeOrb", in: completionSpace)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .animation(.easeOut(duration: Completion.totalDuration), value: rippleScale)
                    .animation(.easeOut(duration: Completion.totalDuration), value: rippleOpacity)
                    .accessibilityHidden(true)
            }

            VStack(spacing: 0) {
                Spacer()

                Text(task.taskText)
                    .font(.serifLarge(40))
                    .foregroundColor(.softBlack)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 64)
                    .accessibilityIdentifier("task.activeText")
                    .dynamicTypeSize(.medium ... .xLarge)
                    .scaleEffect(isCompleting ? 1.06 : 1.0)
                    .opacity(isCompleting ? 0 : 1.0)
                    .blur(radius: isCompleting ? 6 : 0)
                    .animation(.easeInOut(duration: Completion.totalDuration), value: isCompleting)

                if !isCompleting {
                    Button(action: handleComplete) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.primaryChartreuse)
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
                            )
                            .paperShadowLarge()
                    }
                    .buttonStyle(.plain)
                    .matchedGeometryEffect(id: "completeOrb", in: completionSpace)
                    .accessibilityIdentifier("task.complete")
                    .accessibilityLabel(Text(String(localized: "a11y.complete.label")))
                    .accessibilityHint(Text(String(localized: "a11y.complete.hint")))
                    .transition(.opacity)
                } else {
                    Color.clear.frame(width: 80, height: 80)
                }

                Text("FOCUS MODE ACTIVE")
                    .font(.sansTiny(10))
                    .foregroundColor(.mutedForeground.opacity(0.6))
                    .tracking(2)
                    .padding(.top, 32)
                    .opacity(isCompleting ? 0 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isCompleting)
                    .accessibilityHidden(true)

                Spacer()

                Button(action: { showCancelAlert = true }) {
                    Text(String(localized: "task.end_session.button"))
                        .font(.sansSmall(12))
                        .foregroundColor(.mutedForeground.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 48)
                .opacity(isCompleting ? 0 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isCompleting)
                .accessibilityLabel(Text(String(localized: "a11y.end_session.label")))
                .accessibilityHint(Text(String(localized: "a11y.end_session.hint")))
                .disabled(isCompleting)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .parchmentBackground()
        .alert(String(localized: "task.end_session.alert.title"), isPresented: $showCancelAlert) {
            Button(String(localized: "task.end_session.alert.cancel"), role: .cancel) { }
            Button(String(localized: "task.end_session.button"), role: .destructive) {
                HapticManager.shared.error()
                onCancel()
            }
        } message: {
            Text(String(localized: "task.end_session.alert.message"))
        }
        .onDisappear {
            completionTask?.cancel()
            completionTask = nil
        }
    }

    private func handleComplete() {
        guard !isCompleting else { return }
        rippleScale = 1
        rippleOpacity = 0.85
        isCompleting = true

        if reduceMotion {
            completionTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 220_000_000)
                guard !Task.isCancelled else { return }
                HapticManager.shared.success()
                onComplete()
            }
            return
        }

        withAnimation(.easeOut(duration: Completion.totalDuration)) {
            rippleScale = Completion.rippleEndScale
            rippleOpacity = 0
        }

        completionTask = Task { @MainActor in
            let haptic = UInt64(Completion.successHapticDelay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: haptic)
            guard !Task.isCancelled else { return }
            HapticManager.shared.success()

            let remaining = UInt64((Completion.totalDuration - Completion.successHapticDelay) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: remaining)
            guard !Task.isCancelled else { return }
            onComplete()
        }
    }
}

#Preview {
    let schema = Schema([Item.self])
    let container = try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let item = Item(taskText: "Ship the focus polish", timestamp: Date(), isInProgress: true, isCompleted: false)
    return ActiveTaskView(task: item, onComplete: {}, onCancel: {})
        .modelContainer(container)
}
