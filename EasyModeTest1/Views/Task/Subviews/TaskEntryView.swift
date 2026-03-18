//
//  TaskEntryView.swift
//  EasyModeTest1
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
        middle.backgroundColor = Color.primaryOrange.opacity(0.15)
        
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
                .padding(.horizontal, 32)
                .padding(.top, 64)
                
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
                            .tint(.primaryOrange)
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
                                // Haptic feedback on typing
                                if newValue.count > oldValue.count {
                                    HapticManager.shared.selection()
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
                    .padding(.horizontal, 32)
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
                            .background(Color.primaryOrange)
                            .cornerRadius(999)
                            .paperShadow()
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("task.start")
                    .padding(.horizontal, 32)
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
