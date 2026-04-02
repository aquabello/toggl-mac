import SwiftUI

struct TimeBlockView: View {
    let entry: TimeEntry
    let totalHeight: CGFloat
    let onTap: () -> Void

    private var yPosition: CGFloat {
        DateHelpers.timeToYPosition(date: entry.startTime, totalHeight: totalHeight)
    }

    private var blockHeight: CGFloat {
        max(DateHelpers.durationToHeight(duration: entry.duration, totalHeight: totalHeight),
            AppConstants.UI.timeBlockMinHeight)
    }

    private var blockColor: Color {
        if let hex = entry.project?.colorHex {
            return Color(hex: hex)
        }
        return .blue.opacity(0.6)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.taskDescription)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            if blockHeight > 30 {
                Text(DateHelpers.formattedElapsedTime(entry.duration))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: blockHeight)
        .background(blockColor.opacity(0.3))
        .overlay(
            Rectangle()
                .fill(blockColor)
                .frame(width: 3),
            alignment: .leading
        )
        .cornerRadius(4)
        .offset(y: yPosition)
        .onTapGesture(perform: onTap)
    }
}
