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
                let isToday = DateHelpers.isToday(day)

                HStack(spacing: 0) {
                    // Manage +/- buttons area (left side)
                    HStack(spacing: 4) {
                        if isToday {
                            Button(action: {}) {
                                Image(systemName: "minus")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(TogglTheme.textTertiary)
                            }
                            .buttonStyle(.plain)

                            Button(action: {}) {
                                Image(systemName: "plus")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(TogglTheme.textTertiary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(width: 30)

                    Spacer()

                    // Day info
                    VStack(spacing: 2) {
                        // Day number + day name
                        HStack(spacing: 6) {
                            Text("\(DateHelpers.dayNumber(day))")
                                .font(.system(size: 22, weight: isToday ? .bold : .regular).monospacedDigit())
                                .foregroundStyle(isToday ? TogglTheme.todayHighlight : TogglTheme.textPrimary)

                            Text(DateHelpers.dayOfWeekString(day).uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isToday ? TogglTheme.todayHighlight : TogglTheme.textTertiary)
                                .tracking(0.5)
                        }

                        // Daily total
                        if let total = dailyTotals[DateHelpers.dayStart(for: day)], total > 0 {
                            Text(DateHelpers.formattedElapsedTime(total))
                                .font(.system(size: 11).monospacedDigit())
                                .foregroundStyle(TogglTheme.weekTotalText)
                        } else {
                            Text("0:00:00")
                                .font(.system(size: 11).monospacedDigit())
                                .foregroundStyle(TogglTheme.textTertiary.opacity(0.5))
                        }
                    }

                    Spacer()
                    Spacer().frame(width: 30)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .background(TogglTheme.calendarHeaderBg)
    }
}
