import Foundation

enum DateHelpers {
    private static var calendar: Foundation.Calendar {
        var cal = Foundation.Calendar.current
        cal.firstWeekday = AppConstants.Calendar.weekStartDay
        return cal
    }

    static func dayStart(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func dayEnd(for date: Date) -> Date {
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart(for: date)) else {
            return date
        }
        return nextDay
    }

    static func weekStart(for date: Date) -> Date {
        var startOfWeek = date
        var interval: TimeInterval = 0
        _ = calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: date)
        return calendar.startOfDay(for: startOfWeek)
    }

    static func weekEnd(for date: Date) -> Date {
        guard let end = calendar.date(byAdding: .day, value: 7, to: weekStart(for: date)) else {
            return date
        }
        return end
    }

    static func timeToYPosition(date: Date, totalHeight: CGFloat) -> CGFloat {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hours = CGFloat(components.hour ?? 0)
        let minutes = CGFloat(components.minute ?? 0)
        let totalMinutes = hours * 60 + minutes
        return (totalMinutes / (24 * 60)) * totalHeight
    }

    static func durationToHeight(duration: TimeInterval, totalHeight: CGFloat) -> CGFloat {
        let durationMinutes = duration / 60
        return (CGFloat(durationMinutes) / (24 * 60)) * totalHeight
    }

    static func formattedElapsedTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    static func daysInWeek(from weekStart: Date) -> [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    static func dayOfWeekString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    static func dayNumber(_ date: Date) -> Int {
        calendar.component(.day, from: date)
    }
}
