//
//  FocusLiveActivity.swift
//  EasyModeLiveActivity
//
//  Live Activity UI for displaying the current focus task on
//  Lock Screen and Dynamic Island.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FocusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            // Lock Screen / Banner UI
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island (long press)
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "birthday.cake.fill")
                            .font(.title)
                            .foregroundStyle(.orange)
                        Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(86400), countsDown: false)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(primaryTextColor)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    BlockingStatusBadge(isBlocking: context.state.isBlocking)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.taskText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(primaryTextColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 8) {
                        Image(systemName: "birthday.cake.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(86400), countsDown: false)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(secondaryTextColor)
                    }
                }
            } compactLeading: {
                Image(systemName: "birthday.cake.fill")
                    .font(.body)
                    .foregroundStyle(.orange)
            } compactTrailing: {
                HStack(spacing: 4) {
                    Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(86400), countsDown: false)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(primaryTextColor)
                    Image(systemName: context.state.isBlocking ? "lock.fill" : "lock.open")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(context.state.isBlocking ? Color(red: 0.1, green: 0.5, blue: 0.2) : secondaryTextColor)
                }
            } minimal: {
                Image(systemName: "birthday.cake.fill")
                    .foregroundStyle(.orange)
            }
        }
    }
}

// MARK: - High-contrast colors for Lock Screen readability

private let primaryTextColor = Color(red: 0.1, green: 0.1, blue: 0.1)
private let secondaryTextColor = Color(red: 0.25, green: 0.25, blue: 0.25)
private let cardBackgroundColor = Color(white: 0.96)

// MARK: - Blocking Status Badge

private struct BlockingStatusBadge: View {
    let isBlocking: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isBlocking ? "lock.fill" : "lock.open")
                .font(.caption)
                .fontWeight(.semibold)
            Text(isBlocking ? "Blocking" : "Focus")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(isBlocking ? Color(red: 0.1, green: 0.5, blue: 0.2) : secondaryTextColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isBlocking ? Color.green.opacity(0.2) : Color(white: 0.88))
        )
    }
}

// MARK: - Lock Screen View

struct LockScreenView: View {
    let context: ActivityViewContext<FocusActivityAttributes>

    var body: some View {
        HStack(spacing: 20) {
            // Leading icon badge - cake icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 52, height: 52)

                Image(systemName: "birthday.cake.fill")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.orange)
            }

            // Task text and timer
            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.taskText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(2)

                Text(timerInterval: context.attributes.startTime...context.attributes.startTime.addingTimeInterval(86400), countsDown: false)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .foregroundStyle(secondaryTextColor)
            }

            Spacer(minLength: 8)

            // Blocking status chip
            BlockingStatusBadge(isBlocking: context.state.isBlocking)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
        )
        .activityBackgroundTint(cardBackgroundColor)
    }
}

// MARK: - Previews

#if DEBUG
struct FocusLiveActivity_Previews: PreviewProvider {
    static let attributes = FocusActivityAttributes(
        taskText: "Finish the quarterly report",
        startTime: Date()
    )
    static let state = FocusActivityAttributes.ContentState(isBlocking: true)

    static var previews: some View {
        Group {
            attributes
                .previewContext(state, viewKind: .content)
                .previewDisplayName("Lock Screen")

            attributes
                .previewContext(state, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("Dynamic Island Expanded")

            attributes
                .previewContext(state, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("Dynamic Island Compact")

            attributes
                .previewContext(state, viewKind: .dynamicIsland(.minimal))
                .previewDisplayName("Dynamic Island Minimal")
        }
    }
}
#endif
