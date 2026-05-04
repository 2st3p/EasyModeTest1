//
//  LogView.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// View for displaying task completion history matching DigitalDetoxCoach design
/// Shows a list of completed tasks with options to delete individual items or clear all
struct LogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Item> { $0.isCompleted },
        sort: [SortDescriptor(\Item.timestamp, order: .reverse)]
    ) private var completedItems: [Item]
    @StateObject private var viewModel = LogViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(.serifTitle(28))
                    .foregroundColor(.softBlack)
                    .accessibilityIdentifier("log.title")
                Text("\(completedItems.count) tasks completed")
                    .font(.sansSmall(14))
                    .foregroundColor(.mutedForeground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.top, Layout.headerTop)
            .padding(.bottom, 24)
            
            // Content
            if completedItems.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(completedItems, id: \.persistentModelID) { item in
                            HStack(alignment: .top, spacing: 16) {
                                // Checkmark icon
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.success.opacity(0.8))
                                    .clipShape(Circle())
                                    .padding(.top, 2)
                                
                                // Task content
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.taskText)
                                        .font(.sansMedium(16))
                                        .foregroundColor(.softBlack)
                                        .lineLimit(nil)
                                    
                                    Text(relativeTimeString(from: item.timestamp))
                                        .font(.sansSmall(12))
                                        .foregroundColor(.mutedForeground)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, Layout.horizontalPadding)
                            .padding(.vertical, 24)
                            .background(
                                Rectangle()
                                    .fill(Color.clear)
                                    .border(Color.borderColor.opacity(0.2), width: 0.5)
                            )
                        }
                    }
                    .padding(.bottom, Layout.tabBarPadding) // Space for tab bar
                }
            }
        }
        .parchmentBackground()
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Text("\"The journey of a thousand miles begins with a single step.\"")
                .font(.serifBody(18))
                .foregroundColor(.mutedForeground.opacity(0.5))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    LogView()
        .modelContainer(for: Item.self, inMemory: true)
}
