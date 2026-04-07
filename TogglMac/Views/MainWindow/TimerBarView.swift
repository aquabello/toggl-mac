import SwiftUI

struct TimerBarView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Task description input
            HStack(spacing: 10) {
                TextField("What are you working on?", text: $viewModel.taskDescription)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .foregroundStyle(TogglTheme.textPrimary)

                if viewModel.isRunning {
                    Text(viewModel.taskDescription.isEmpty ? "No description" : "")
                        .font(.system(size: 14))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Right side: icon group + today label + timer + stop button
            HStack(spacing: 16) {
                // Icon group
                HStack(spacing: 12) {
                    iconButton("folder", tooltip: "Project")
                    iconButton("tag", tooltip: "Tags")
                    iconButton("dollarsign.circle", tooltip: "Billable")
                }
                .padding(.trailing, 8)

                // Today's total time
                if viewModel.todayTotalTime > 0 {
                    Text("Today \(DateHelpers.formattedElapsedTime(viewModel.todayTotalTime))")
                        .font(.system(size: 10))
                        .foregroundStyle(TogglTheme.textTertiary)
                }

                // Timer display
                Text(viewModel.formattedElapsedTime)
                    .font(.system(size: 20, weight: .medium).monospacedDigit())
                    .foregroundStyle(viewModel.isRunning ? TogglTheme.textPrimary : TogglTheme.textSecondary)
                    .frame(minWidth: 100, alignment: .trailing)

                // Play/Stop button
                Button(action: { viewModel.toggle() }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.isRunning ? TogglTheme.timerStopButton : TogglTheme.accentPink)
                            .frame(width: 36, height: 36)

                        Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .help(viewModel.isRunning ? "Stop timer" : "Start timer")

                // More options
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundStyle(TogglTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(TogglTheme.timerBarBackground)
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                // Daily progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(TogglTheme.surfaceCard)
                            .frame(height: 3)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [TogglTheme.accentPink.opacity(0.7), TogglTheme.accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.todayProgress, height: 3)
                            .animation(.linear(duration: 1.0), value: viewModel.todayProgress)
                    }
                }
                .frame(height: 3)

                Rectangle()
                    .fill(TogglTheme.divider)
                    .frame(height: 1)
            }
        }
    }

    private func iconButton(_ systemName: String, tooltip: String) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 14))
                .foregroundStyle(TogglTheme.textTertiary)
        }
        .buttonStyle(.plain)
        .help(tooltip)
    }
}
