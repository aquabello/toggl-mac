import Foundation
import Carbon.HIToolbox

enum AppConstants {
    static let appName = "TogglMac"
    static let defaultTaskDescription = "제목 없음"

    enum Hotkey {
        static let toggleTimerKeyCode: UInt32 = UInt32(kVK_ANSI_T)
        static let toggleTimerModifiers: UInt32 = UInt32(cmdKey | controlKey)
    }

    enum Calendar {
        static let hoursInDay = 24
        static let hourHeight: CGFloat = 60.0
        static let totalDayHeight: CGFloat = CGFloat(hoursInDay) * hourHeight
        static let weekStartDay = 2 // Monday (Calendar.Component.weekday: 2=Mon)
    }

    enum UI {
        static let sidebarWidth: CGFloat = 200.0
        static let timerBarHeight: CGFloat = 60.0
        static let timeBlockMinHeight: CGFloat = 20.0
    }
}
