import SwiftUI

// MARK: - Toggl Track Dark Charcoal Theme

enum TogglTheme {
    // MARK: - Background Colors
    static let backgroundPrimary = Color(hex: "161619")    // Deepest background
    static let backgroundSecondary = Color(hex: "1E1E24")  // Main content area
    static let backgroundTertiary = Color(hex: "2A2A32")   // Elevated surfaces
    static let backgroundSidebar = Color(hex: "1A1A1F")    // Sidebar background

    // MARK: - Surface Colors
    static let surfaceCard = Color(hex: "282830")          // Card/panel background
    static let surfaceHover = Color(hex: "32323C")         // Hover state
    static let surfaceSelected = Color(hex: "3A3A46")      // Selected state
    static let surfaceInput = Color(hex: "222228")         // Input field background

    // MARK: - Accent Colors
    static let accentPink = Color(hex: "E57CD8")           // Primary accent (Toggl pink)
    static let accentPinkLight = Color(hex: "F0A0E8")      // Light pink
    static let accentRed = Color(hex: "E74C3C")            // Stop button / destructive
    static let accentGreen = Color(hex: "2ECC71")          // Running timer
    static let accentBlue = Color(hex: "3498DB")           // Links / today

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0B0")        // Muted text
    static let textTertiary = Color(hex: "6A6A78")         // Very muted text
    static let textPlaceholder = Color(hex: "585868")      // Placeholder text

    // MARK: - Border & Divider
    static let divider = Color(hex: "2A2A32").opacity(0.8)
    static let border = Color(hex: "32323C")
    static let gridLine = Color(hex: "2A2A32").opacity(0.5)

    // MARK: - Timer Bar
    static let timerBarBackground = Color(hex: "1E1E24")
    static let timerStopButton = Color(hex: "E74C3C")
    static let timerRunningText = Color(hex: "2ECC71")

    // MARK: - Calendar
    static let calendarHeaderBg = Color(hex: "1E1E24")
    static let currentTimeIndicator = Color(hex: "E57CD8")
    static let todayHighlight = Color(hex: "E57CD8")
    static let weekTotalText = Color(hex: "A0A0B0")

    // MARK: - Sidebar Section Labels
    static let sectionLabel = Color(hex: "6A6A78")

    // MARK: - Tab Bar
    static let tabActive = Color(hex: "E57CD8")
    static let tabInactive = Color(hex: "6A6A78")
    static let tabBackground = Color(hex: "2A2A32")

    // MARK: - Project Colors (vibrant for dark bg)
    static let projectColors = [
        "E57CD8", "4ECDC4", "45B7D1", "96CEB4",
        "FFD93D", "FF6B6B", "C39BD3", "F7DC6F",
        "76D7C4", "85C1E9", "F0B27A", "AED6F1"
    ]
}

// MARK: - View Modifiers

struct TogglCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(TogglTheme.surfaceCard)
            .cornerRadius(8)
    }
}

struct TogglInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(TogglTheme.surfaceInput)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(TogglTheme.border, lineWidth: 1)
            )
    }
}

extension View {
    func togglCard() -> some View {
        modifier(TogglCardStyle())
    }

    func togglInput() -> some View {
        modifier(TogglInputStyle())
    }
}