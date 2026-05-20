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

/// Single SF Symbol that represents an active focus session.
/// Kept here so the choice is changed in one place. The previous mark was
/// `birthday.cake.fill`; switched to `circle.hexagongrid.fill` so the brand
/// reads as deliberate focus rather than confetti.
private let brandFocusSymbol = "circle.hexagongrid.fill"

/// Conservative far-future endpoint for the elapsed-time `timerInterval`.
/// SwiftUI's `timerInterval` keeps counting up until the end of this window;
/// we use 24h since real focus sessions are bounded well below that.
private let sessionTimerWindow: TimeInterval = 86_400

// MARK: - Brand colors (canonical: Shared/BrandRGB.swift)

private func brandColor(_ rgb: (red: Double, green: Double, blue: Double)) -> Color {
    Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
}

private let primaryTextColor = brandColor(BrandRGB.softBlack)
private let secondaryTextColor = brandColor(BrandRGB.mutedForeground)
private let cardBackgroundColor = brandColor(BrandRGB.parchment)
private let chartreuse = brandColor(BrandRGB.chartreuse)
private let blockingGreen = brandColor(BrandRGB.blockingGreen)

/// Shared Easy Mode mark for Dynamic Island + Lock Screen (matches shield extension asset).
private struct BrandMark: View {
    var font: Font = .body
    var weight: Font.Weight = .regular

    var body: some View {
        Image(systemName: brandFocusSymbol)
            .font(font)
            .fontWeight(weight)
            .foregroundStyle(chartreuse)
    }
}

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
                        BrandMark(font: .title)
                        sessionTimer(start: context.attributes.startTime, font: .caption)
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
                        BrandMark(font: .caption)
                        sessionTimer(start: context.attributes.startTime, font: .subheadline)
                            .foregroundStyle(secondaryTextColor)
                    }
                }
            } compactLeading: {
                BrandMark(font: .body)
            } compactTrailing: {
                HStack(spacing: 4) {
                    sessionTimer(start: context.attributes.startTime, font: .caption2)
                        .foregroundStyle(primaryTextColor)
                    Image(systemName: context.state.isBlocking ? "lock.fill" : "lock.open")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(context.state.isBlocking ? blockingGreen : secondaryTextColor)
                }
            } minimal: {
                BrandMark(font: .caption2)
            }
        }
    }
}

@ViewBuilder
private func sessionTimer(start: Date, font: Font) -> some View {
    Text(timerInterval: start...start.addingTimeInterval(sessionTimerWindow), countsDown: false)
        .font(font)
        .fontWeight(.semibold)
        .monospacedDigit()
}

// MARK: - Blocking Status Badge

private struct BlockingStatusBadge: View {
    let isBlocking: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isBlocking ? "lock.fill" : "lock.open")
                .font(.caption)
                .fontWeight(.semibold)
            Text(isBlocking
                ? String(localized: "liveactivity.blocking", bundle: .main)
                : String(localized: "liveactivity.focus", bundle: .main))
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(isBlocking ? blockingGreen : secondaryTextColor)
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(chartreuse.opacity(0.3))
                    .frame(width: 52, height: 52)

                BrandMark(font: .title2, weight: .bold)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(context.attributes.taskText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(2)

                sessionTimer(start: context.attributes.startTime, font: .subheadline)
                    .foregroundStyle(secondaryTextColor)
            }

            Spacer(minLength: 8)

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
