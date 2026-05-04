//
//  TaskEntryView.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI

/// View for entering a new task matching DigitalDetoxCoach design
/// Provides a text field for task input and a button to create the task
struct TaskEntryView: View {
    /// The current text input for the task
    @Binding var taskInput: String
    /// Callback function to execute when the task is submitted
    let onSubmit: () -> Void
    /// Focus state for the text field
    @FocusState private var isTextFieldFocused: Bool
    /// Counter for debounced haptic feedback
    @State private var hapticCounter = 0

    private let maxLength = 90
    private var isInputValid: Bool {
        !taskInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var titleAttributedString: AttributedString {
        var start = AttributedString("What do you want to ")
        start.font = .serifTitle(36)
        start.foregroundColor = .softBlack
        
        var middle = AttributedString("accomplish")
        middle.font = .serifTitle(36)
        middle.foregroundColor = .softBlack
        middle.backgroundColor = Color.primaryChartreuse.opacity(0.15)
        
        var end = AttributedString(" next?")
        end.font = .serifTitle(36)
        end.foregroundColor = .softBlack
        
        return start + middle + end
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isTextFieldFocused = false
                }

            VStack(spacing: 0) {
                // Title section
                VStack(alignment: .leading, spacing: 0) {
                    Text(titleAttributedString)
                        .fixedSize(horizontal: false, vertical: true) // Ensure it wraps
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.headerTop)
                
                Spacer()
                
                // Input section
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField(
                            "",
                            text: $taskInput,
                            prompt: Text("I want to...")
                                .font(.serifLarge(28))
                                .foregroundStyle(Color(uiColor: .systemGray3)),
                            axis: .vertical
                        )
                            .font(.serifLarge(28))
                            .foregroundColor(.softBlack)
                            .tint(.primaryChartreuse)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .accessibilityIdentifier("task.input")
                            .lineLimit(1...)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)
                            .overlay(
                                Rectangle()
                                    .frame(height: isTextFieldFocused ? 2 : 1.5)
                                    .foregroundColor(isTextFieldFocused ? Color(uiColor: .systemGray) : Color(uiColor: .systemGray))
                                    .shadow(
                                        color: isTextFieldFocused ? Color(uiColor: .systemGray4) : .clear,
                                        radius: 2,
                                        y: 1
                                    )
                                    .offset(y: 16),
                                alignment: .bottom
                            )
                            .onChange(of: taskInput) { oldValue, newValue in
                                // Debounced haptic feedback every 4 characters
                                if newValue.count > oldValue.count {
                                    hapticCounter += 1
                                    if hapticCounter >= 4 {
                                        HapticManager.shared.selection()
                                        hapticCounter = 0
                                    }
                                } else if newValue.count < oldValue.count {
                                    // Reset counter when deleting
                                    hapticCounter = 0
                                }
                                // Limit to maxLength (enforced but not displayed)
                                if newValue.count > maxLength {
                                    taskInput = String(newValue.prefix(maxLength))
                                    HapticManager.shared.impact()
                                }
                            }
                            .onSubmit {
                                isTextFieldFocused = false
                            }
                    }
                    .padding(.horizontal, Layout.horizontalPadding)
                }

                Spacer()

                // Start Focus button
                if isInputValid {
                    Button(action: {
                        HapticManager.shared.impact()
                        isTextFieldFocused = false
                        onSubmit()
                    }) {
                        Text("Start Focus")
                            .font(.sansMedium(18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primaryChartreuse)
                            .cornerRadius(999)
                            .paperShadow()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("task.start")
                    .padding(.horizontal, Layout.horizontalPadding)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .parchmentBackground()
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isInputValid)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTextFieldFocused)
    }
}
