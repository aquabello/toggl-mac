import SwiftUI

struct TimeBlockView: View {
    let entry: TimeEntry
    let totalHeight: CGFloat
    let onTap: () -> Void
    var onDelete: (() -> Void)?
    var onMove: ((CGFloat) -> Void)?  // Called with Y delta in totalHeight coordinates

    @State private var isHovering = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var columnIndex: Int = 0
    var totalColumns: Int = 1

    var yPosition: CGFloat {
        max(0, DateHelpers.timeToYPosition(date: entry.startTime, totalHeight: totalHeight))
    }

    var blockHeight: CGFloat {
        let h = DateHelpers.durationToHeight(duration: max(0, entry.duration), totalHeight: totalHeight)
        return max(h.isFinite ? h : 0, AppConstants.UI.timeBlockMinHeight)
    }

    private var blockColor: Color {
        if let hex = entry.project?.colorHex {
            return Color(hex: hex)
        }
        return TogglTheme.accentPink.opacity(0.7)
    }

    private var durationIntensity: Double {
        // 15 min = 0.0 (minimum), 2 hours+ = 1.0 (maximum)
        let minutes = entry.duration / 60.0
        let normalized = (minutes - 15.0) / (120.0 - 15.0) // 15min to 120min range
        return min(max(normalized, 0.0), 1.0)
    }

    private var bgOpacity: Double {
        0.2 + durationIntensity * 0.35  // range: 0.2 to 0.55
    }

    private var gradientOpacity: Double {
        0.05 + durationIntensity * 0.1  // range: 0.05 to 0.15
    }

    private var strokeOpacity: Double {
        0.2 + durationIntensity * 0.3  // range: 0.2 to 0.5
    }

    private var shadowOpacity: Double {
        0.1 + durationIntensity * 0.2  // range: 0.1 to 0.3
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
                .fill(blockColor.opacity(bgOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [blockColor.opacity(gradientOpacity), blockColor.opacity(gradientOpacity * 0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(blockColor.opacity(strokeOpacity), lineWidth: 1)
        )
        .overlay(
            Rectangle()
                .fill(blockColor)
                .frame(width: 3 + durationIntensity * 1.5)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 6,
                        bottomLeadingRadius: 6
                    )
                ),
            alignment: .leading
        )
        .overlay(alignment: .topTrailing) {
            if isHovering {
                Button(action: { onDelete?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(Color.red.opacity(0.8)))
                }
                .buttonStyle(.plain)
                .padding(4)
                .help("Delete")
            }
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .offset(y: yPosition + dragOffset)
        .opacity(isDragging ? 0.7 : 1.0)
        .onTapGesture(perform: onTap)
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    isDragging = true
                    // Snap to 15-minute increments
                    let minuteHeight = totalHeight / (24 * 60)
                    let rawOffset = value.translation.height
                    let snapMinutes = round(rawOffset / (minuteHeight * 15)) * 15
                    dragOffset = snapMinutes * minuteHeight
                }
                .onEnded { _ in
                    isDragging = false
                    if dragOffset != 0 {
                        onMove?(dragOffset)
                    }
                    dragOffset = 0
                }
        )
        .contextMenu {
            Button(action: onTap) {
                Label("Edit", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: { onDelete?() }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .shadow(color: blockColor.opacity(shadowOpacity), radius: 4, y: 2)
    }
}
