//
//  BlockView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// View for managing blocked apps matching DigitalDetoxCoach design
/// Displays a list of available apps and allows toggling them on/off
struct BlockView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var blockedApps: [BlockedApp]
    @StateObject private var viewModel = BlockViewModel()
    @State private var showingAppPicker = false
    
    // Get set of blocked app names for quick lookup
    private var blockedAppNames: Set<String> {
        Set(blockedApps.map(\.appName))
    }
    
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
                    
                    // Blocked Apps section header
                    VStack(alignment: .leading, spacing: 0) {
                        Text("BLOCKED APPS")
                            .font(.sansTiny(10))
                            .foregroundColor(.mutedForeground.opacity(0.6))
                            .tracking(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    // App list
                    VStack(spacing: 0) {
                        ForEach(AvailableApps.apps, id: \.self) { appName in
                            let isBlocked = blockedAppNames.contains(appName)
                            
                            Button(action: {
                                HapticManager.shared.selection()
                                toggleApp(appName)
                            }) {
                                HStack {
                                    Text(appName)
                                        .font(isBlocked ? .sansMedium(18) : .sansBody(18))
                                        .foregroundColor(isBlocked ? .softBlack : .mutedForeground)
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(isBlocked ? Color.primaryOrange : Color.clear)
                                            .frame(width: 24, height: 24)
                                        
                                        Circle()
                                            .stroke(isBlocked ? Color.primaryOrange : Color.borderColor.opacity(0.2), lineWidth: 2)
                                            .frame(width: 24, height: 24)
                                        
                                        if isBlocked {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    Rectangle()
                                        .fill(Color.clear)
                                        .border(Color.borderColor.opacity(0.2), width: 0.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    // Add more apps button
                    Button(action: {
                        HapticManager.shared.impact()
                        showingAppPicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                            Text("Add more apps")
                                .font(.sansBody(16))
                        }
                        .foregroundColor(.mutedForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(.borderColor.opacity(0.2))
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80) // Space for tab bar
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func toggleApp(_ appName: String) {
        let isCurrentlyBlocked = blockedAppNames.contains(appName)
        
        if isCurrentlyBlocked {
            // Remove from blocked apps
            if let app = blockedApps.first(where: { $0.appName == appName }) {
                modelContext.delete(app)
                do {
                    try modelContext.save()
                } catch {
                    viewModel.handleError(error)
                }
            }
        } else {
            // Add to blocked apps (using appName as bundleID for now)
            let bundleID = "com.\(appName.lowercased().replacingOccurrences(of: " ", with: ""))"
            let newApp = BlockedApp(bundleID: bundleID, appName: appName)
            modelContext.insert(newApp)
            do {
                try modelContext.save()
            } catch {
                viewModel.handleError(error)
            }
        }
    }
}

#Preview {
    BlockView()
        .modelContainer(for: BlockedApp.self, inMemory: true)
}
