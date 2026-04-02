import SwiftUI

struct TimeBlockView: View {
    let entry: TimeEntry
    let totalHeight: CGFloat
    let onTap: () -> Void

    private var yPosition: CGFloat {
        max(0, DateHelpers.timeToYPosition(date: entry.startTime, totalHeight: totalHeight))
    }

    private var blockHeight: CGFloat {
        let h = DateHelpers.durationToHeight(duration: max(0, entry.duration), totalHeight: totalHeight)
        return max(h.isFinite ? h : 0, AppConstants.UI.timeBlockMinHeight)
    }

    private var blockColor: Color {
        if let hex = entry.project?.colorHex {
            return Color(hex: hex)
        }
        return TogglTheme.accentPink.opacity(0.7)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.taskDescription)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)

            if blockHeight > 30 {
                Text(DateHelpers.formattedElapsedTime(entry.duration))
                    .font(.system(size: 10).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: blockHeight)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(blockColor.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [blockColor.opacity(0.1), blockColor.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(blockColor.opacity(0.3), lineWidth: 1)
        )
        .overlay(
            Rectangle()
                .fill(blockColor)
                .frame(width: 3)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 6
                    )
                ),
            alignment: .leading
        )
        .offset(y: yPosition)
        .onTapGesture(perform: onTap)
        .shadow(color: blockColor.opacity(0.2), radius: 4, y: 2)
    }
}
