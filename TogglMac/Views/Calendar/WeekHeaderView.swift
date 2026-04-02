import SwiftUI

struct WeekHeaderView: View {
    let days: [Date]
    let dailyTotals: [Date: TimeInterval]

    var body: some View {
        HStack(spacing: 0) {
            // Time label column spacer
            Text("")
                .frame(width: 50)

            ForEach(days, id: \.self) { day in
                VStack(spacing: 2) {
                    Text(DateHelpers.dayOfWeekString(day))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(DateHelpers.dayNumber(day))")
                        .font(.title2)
                        .fontWeight(DateHelpers.isToday(day) ? .bold : .regular)
                        .foregroundStyle(DateHelpers.isToday(day) ? .blue : .primary)

                    if let total = dailyTotals[DateHelpers.dayStart(for: day)], total > 0 {
                        Text(DateHelpers.formattedElapsedTime(total))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("0:00:00")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }
}
