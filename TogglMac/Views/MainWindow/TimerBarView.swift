import SwiftUI

struct TimerBarView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        HStack(spacing: 12) {
            TextField("What are you working on?", text: $viewModel.taskDescription)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .disabled(viewModel.isRunning)

            Text(viewModel.formattedElapsedTime)
                .font(.system(size: 14, weight: .medium).monospacedDigit())
                .foregroundStyle(viewModel.isRunning ? Color.green : Color.secondary)
                .frame(minWidth: 70, alignment: .trailing)

            Button(action: { viewModel.toggle() }) {
                Image(systemName: viewModel.isRunning ? "stop.fill" : "play.fill")
                    .foregroundStyle(viewModel.isRunning ? Color.green : Color.accentColor)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            .help(viewModel.isRunning ? "Stop timer" : "Start timer")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}
