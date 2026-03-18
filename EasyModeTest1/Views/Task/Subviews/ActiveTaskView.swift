//
//  ActiveTaskView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

/// View for displaying and completing an active task matching DigitalDetoxCoach design
/// Shows the current task text and provides buttons to complete or cancel
struct ActiveTaskView: View {
    /// The task being displayed and managed
    let task: Item
    /// Callback function to execute when the task is completed
    let onComplete: () -> Void
    /// Callback function to execute when the task is cancelled
    let onCancel: () -> Void
    
    @State private var isCompleting = false
    @State private var showCancelAlert = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0.8
    
    var body: some View {
        ZStack {
            // Completion ripple effect
            if isCompleting {
                Circle()
                    .fill(Color.primaryOrange)
                    .frame(width: 256, height: 256)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .animation(.easeOut(duration: 2.0), value: rippleScale)
                    .animation(.easeOut(duration: 2.0), value: rippleOpacity)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Task text
                Text(task.taskText)
                    .font(.serifLarge(40))
                    .foregroundColor(.softBlack)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 64)
                    .accessibilityIdentifier("task.activeText")
                    .scaleEffect(isCompleting ? 1.2 : 1.0)
                    .opacity(isCompleting ? 0 : 1.0)
                    .blur(radius: isCompleting ? 10 : 0)
                    .animation(.easeInOut(duration: 2.0), value: isCompleting)
                
                // Complete button
                Button(action: handleComplete) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.primaryOrange)
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
                .accessibilityIdentifier("task.complete")
                .scaleEffect(isCompleting ? 0 : 1.0)
                .opacity(isCompleting ? 0 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleting)
                
                // Focus Mode Active indicator
                Text("FOCUS MODE ACTIVE")
                    .font(.sansTiny(10))
                    .foregroundColor(.mutedForeground.opacity(0.6))
                    .tracking(2)
                    .padding(.top, 32)
                    .opacity(isCompleting ? 0 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isCompleting)
                
                Spacer()
                
                // Give Up button
                Button(action: { showCancelAlert = true }) {
                    Text("Give Up")
                        .font(.sansSmall(12))
                        .foregroundColor(.mutedForeground.opacity(0.5))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 48)
                .opacity(isCompleting ? 0 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isCompleting)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .parchmentBackground()
        .alert("Stop Focusing?", isPresented: $showCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                HapticManager.shared.error()
                onCancel()
            }
        } message: {
            Text("You'll lose progress on this session.")
        }
    }
    
    private func handleComplete() {
        HapticManager.shared.heavyImpact()
        isCompleting = true
        
        // Start ripple animation
        withAnimation(.easeOut(duration: 2.0)) {
            rippleScale = 4.0
            rippleOpacity = 0
        }
        
        // Wait for animation then complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            HapticManager.shared.success()
            onComplete()
        }
    }
}
