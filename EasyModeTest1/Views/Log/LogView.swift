//
//  LogView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// Shows a chronological list of completed tasks.
struct LogView: View {
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.selectHomeTab) private var selectHomeTab

    @Query(
        filter: #Predicate<Item> { $0.isCompleted },
        sort: [SortDescriptor(\Item.timestamp, order: .reverse)]
    ) private var completedItems: [Item]
    @StateObject private var viewModel = LogViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "log.history.title"))
                        .font(.serifTitle(28))
                        .foregroundColor(.softBlack)
                        .accessibilityIdentifier("log.title")
                    Text(completedCountDescription)
                        .font(.sansSmall(14))
                        .foregroundColor(.mutedForeground)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.headerTop)
                .padding(.bottom, 24)

                if completedItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(completedItems, id: \.persistentModelID) { item in
                                logRow(for: item)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(reduceMotion ? .linear(duration: 0.001) : .easeOut(duration: 0.28), value: completedItems.count)
                        .padding(.bottom, Layout.tabBarPadding)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !completedItems.isEmpty {
                        Button(String(localized: "log.clear_all")) {
                            clearAllCompleted()
                        }
                        .font(.sansMedium(16))
                    }
                }
            }
        }
        .parchmentBackground()
        .alert(String(localized: "alert.error.title"), isPresented: $viewModel.showError) {
            Button(String(localized: "alert.ok"), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }

    private var completedCountDescription: String {
        String(format: String(localized: "log.tasks_completed.format"), completedItems.count)
    }

    private func logRow(for item: Item) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.primaryChartreuse.opacity(0.85))
                .clipShape(Circle())
                .padding(.top, 2)
                .accessibilityHidden(true)

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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text("\(item.taskText), \(relativeTimeString(from: item.timestamp))")
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                delete(item)
            } label: {
                Label(String(localized: "log.delete"), systemImage: "trash")
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Text(String(localized: "log.empty.quote"))
                .font(.serifBody(18))
                .foregroundColor(.mutedForeground.opacity(0.72))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: {
                HapticManager.shared.impact()
                selectHomeTab()
            }) {
                Text(String(localized: "log.empty.cta"))
                    .font(.sansMedium(16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(Color.primaryChartreuse)
                    .clipShape(Capsule())
                    .paperShadow()
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func relativeTimeString(from date: Date) -> String {
        Self.relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    private func delete(_ item: Item) {
        modelContext.delete(item)
        do {
            try modelContext.save()
        } catch {
            viewModel.handleError(error)
        }
    }

    private func clearAllCompleted() {
        do {
            try viewModel.clearAll(completedItems, using: modelContext)
        } catch {
            viewModel.handleError(error)
        }
    }
}

#Preview {
    LogView()
        .modelContainer(for: Item.self, inMemory: true)
}
