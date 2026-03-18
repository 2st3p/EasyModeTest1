//
//  BlockView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// View for managing blocked apps matching DigitalDetoxCoach design
/// Empty state uses copy and category icons to inspire users; single CTA opens FamilyActivityPicker
struct BlockView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var blockedApps: [BlockedApp]
    @StateObject private var viewModel = BlockViewModel()
    @State private var showingAppPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.serifTitle(28))
                    .foregroundColor(.softBlack)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 48)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Strict Blocking info card
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.secondaryPink)
                            .frame(width: 40, height: 40)
                            .background(Color.white)
                            .cornerRadius(12)
                            .paperShadow()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Strict Blocking")
                                .font(.sansMedium(16))
                                .foregroundColor(.softBlack)
                            Text("Selected apps will be completely inaccessible during Focus Mode sessions.")
                                .font(.sansSmall(14))
                                .foregroundColor(.mutedForeground)
                                .lineSpacing(2)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondaryPink.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    
                    if viewModel.hasSelectedApps {
                        nonEmptyState
                    } else {
                        emptyState
                    }
                }
            }
        }
        .parchmentBackground()
        .sheet(isPresented: $showingAppPicker) {
            AppSelectionSheet(
                blockedApps: blockedApps,
                viewModel: viewModel
            )
        }
        .task {
            viewModel.syncSelection()
        }
        .onChange(of: showingAppPicker) { _, isShowing in
            if !isShowing {
                viewModel.syncSelection()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            // Inspirational copy
            Text("What pulls you away from deep work?")
                .font(.serifTitle(24))
                .foregroundColor(.softBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Text("Social feeds, games, messaging—choose what to block during focus.")
                .font(.sansBody(16))
                .foregroundColor(.mutedForeground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
            
            // Category icons to spark thinking
            HStack(spacing: 24) {
                CategoryIcon(systemName: "bubble.left.and.bubble.right.fill", label: "Social")
                CategoryIcon(systemName: "gamecontroller.fill", label: "Games")
                CategoryIcon(systemName: "envelope.fill", label: "Messages")
                CategoryIcon(systemName: "newspaper.fill", label: "News")
                CategoryIcon(systemName: "play.rectangle.fill", label: "Video")
            }
            .padding(.vertical, 16)
            
            // Single CTA
            Button(action: {
                HapticManager.shared.impact()
                showingAppPicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18))
                    Text("Choose Apps to Block")
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
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
    }
    
    // MARK: - Non-Empty State
    
    private var nonEmptyState: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 0) {
                Text("BLOCKED APPS")
                    .font(.sansTiny(10))
                    .foregroundColor(.mutedForeground.opacity(0.6))
                    .tracking(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            // Selection summary
            HStack {
                Text("\(viewModel.selectedCount) item\(viewModel.selectedCount == 1 ? "" : "s") blocked")
                    .font(.sansMedium(16))
                    .foregroundColor(.softBlack)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.impact()
                    showingAppPicker = true
                }) {
                    Text("Change")
                        .font(.sansMedium(16))
                        .foregroundColor(.primaryOrange)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
            )
            .paperShadow()
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 80)
    }
}

// MARK: - Category Icon

private struct CategoryIcon: View {
    let systemName: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(.mutedForeground.opacity(0.7))
                .frame(width: 44, height: 44)
                .background(Color.mutedBackground)
                .cornerRadius(12)
            
            Text(label)
                .font(.sansTiny(10))
                .foregroundColor(.mutedForeground.opacity(0.6))
        }
    }
}

#Preview {
    BlockView()
        .modelContainer(for: BlockedApp.self, inMemory: true)
}
