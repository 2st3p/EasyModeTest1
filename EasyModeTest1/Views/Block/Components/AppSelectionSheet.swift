//
//  AppSelectionSheet.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData
#if canImport(FamilyControls)
import FamilyControls
#endif

/// Sheet for selecting apps to block
/// Uses FamilyActivityPicker on devices that support it, falls back to mock selection for simulator
struct AppSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let blockedApps: [BlockedApp]
    @ObservedObject var viewModel: BlockViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                #if canImport(FamilyControls)
                if viewModel.isAuthorized {
                    FamilyActivityPicker(selection: $viewModel.selection)
                } else {
                    authorizationView
                }
                #else
                mockSelectionView
                #endif
            }
            .navigationTitle(String(localized: "block.choose_apps.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "block.choose_apps.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "block.choose_apps.done")) {
                        saveSelection()
                        dismiss()
                    }
                    #if canImport(FamilyControls)
                    .disabled(!viewModel.isAuthorized)
                    #endif
                }
            }
        }
        #if canImport(FamilyControls)
        .task {
            await viewModel.refreshAuthorizationStatus()
        }
        #endif
    }
    
    #if canImport(FamilyControls)
    private var authorizationView: some View {
        VStack(spacing: 16) {
            Text(String(localized: "block.choose_apps.auth_message"))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(viewModel.isRequestingAuth
                ? String(localized: "block.choose_apps.requesting")
                : String(localized: "block.choose_apps.grant_access")) {
                Task {
                    await viewModel.requestAuthorization()
                }
            }
            .disabled(viewModel.isRequestingAuth)
        }
        .padding()
    }
    #endif
    
    #if !canImport(FamilyControls)
    @State private var selectedApps: Set<String> = []
    
    private var mockSelectionView: some View {
        List {
            ForEach(["com.apple.safari", "com.apple.mail", "com.apple.messages"], id: \.self) { bundleID in
                let isSelected = selectedApps.contains(bundleID)
                Button(action: {
                    if isSelected {
                        selectedApps.remove(bundleID)
                    } else {
                        selectedApps.insert(bundleID)
                    }
                }) {
                    HStack {
                        Text(bundleID.components(separatedBy: ".").last ?? "")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .onAppear {
            selectedApps = Set(blockedApps.map(\.bundleID))
        }
    }
    #endif
    
    /// Saves the selected apps based on the current platform capabilities
    private func saveSelection() {
        do {
            #if canImport(FamilyControls)
            try viewModel.saveSelectedApps(blockedApps, using: modelContext)
            #else
            try viewModel.saveMockSelectedApps(selectedApps, from: blockedApps, using: modelContext)
            #endif
        } catch {
            viewModel.handleError(error)
        }
    }
}

#if DEBUG
#Preview {
    AppSelectionSheet(blockedApps: [], viewModel: BlockViewModel())
        .modelContainer(for: BlockedApp.self, inMemory: true)
}
#endif
